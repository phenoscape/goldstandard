//> using scala 3.7
//> using dep "net.sourceforge.owlapi:owlapi-distribution:4.5.29"
//> using dep "com.lihaoyi::os-lib:0.11.4"
//> using dep "com.lihaoyi::fansi:0.5.0"
//> using dep "com.lihaoyi::sourcecode:0.4.2"

import org.semanticweb.owlapi.apibinding.OWLManager
import org.semanticweb.owlapi.model.*
import org.semanticweb.owlapi.expression.OWLEntityChecker
import org.semanticweb.owlapi.manchestersyntax.parser.ManchesterOWLSyntaxParserImpl
import org.semanticweb.owlapi.vocab.OWLRDFVocabulary

import scala.jdk.CollectionConverters.*
import scala.util.{Try, Success, Failure}
import scala.collection.mutable

// ---------------------------------------------------------------------------
// Known relation CURIEs and their labels used in annotation post-compositions.
// These are authoritative — some may not appear as OBO Typedef stanzas or may
// have different xref mappings in current OBO versions.
// ---------------------------------------------------------------------------
val KnownRelations: Map[String, String] = Map(
  "BFO:0000050"  -> "part_of",
  "BFO:0000051"  -> "has_part",
  "BFO:0000052"  -> "inheres_in",
  "BFO:0000053"  -> "bearer_of",
  "RO:0002150"   -> "continuous_with",
  "RO:0002170"   -> "connected_to",
  "RO:0002176"   -> "connects",
  "RO:0002220"   -> "adjacent_to",
  "RO:0002371"   -> "attaches_to",
  "BSPO:0000096" -> "anterior_to",
  "BSPO:0000097" -> "distal_to",
  "BSPO:0000098" -> "dorsal_to",
  "BSPO:0000099" -> "posterior_to",
  "BSPO:0000102" -> "ventral_to",
  "BSPO:0000120" -> "in_left_side_of",
  "BSPO:0000121" -> "in_right_side_of",
  "PHENOSCAPE:complement_of" -> "not",
  "PHENOSCAPE:extends_from"  -> "extends_from",
  "PHENOSCAPE:extends_to"    -> "extends_to",
  "PATO:0002304" -> "decreased_in_magnitude_relative_to",
  "PATO:0002305" -> "increased_in_magnitude_relative_to",
  "PATO:0002306" -> "similar_in_magnitude_relative_to",
  "UBERON:attaches_to"                  -> "attaches_to",
  "UBERON:encloses"                     -> "encloses",
  "UBERON:has_muscle_insertion"         -> "has_muscle_insertion",
  "UBERON:has_muscle_origin"            -> "has_muscle_origin",
  "UBERON:connects"                     -> "connects",
  "UBERON:connected_to"                 -> "connected_to",
  "UBERON:continuous_with"              -> "continuous_with",
  "UBERON:anteriorly_connected_to"      -> "anteriorly_connected_to",
  "UBERON:posteriorly_connected_to"     -> "posteriorly_connected_to",
  "UBERON:in_lateral_side_of"           -> "in_lateral_side_of",
  "UBERON:in_median_plane_of"           -> "in_median_plane_of",
)

// OBO IRI base
val OboBase = "http://purl.obolibrary.org/obo/"

// ---------------------------------------------------------------------------
// CURIE <-> IRI conversion
// ---------------------------------------------------------------------------
def curieToIRI(curie: String): IRI =
  val idx = curie.indexOf(':')
  if idx > 0 then
    val prefix = curie.substring(0, idx)
    val local  = curie.substring(idx + 1)
    IRI.create(OboBase + prefix + "_" + local)
  else
    IRI.create(OboBase + curie)

def iriToCurie(iri: IRI): String =
  val s = iri.toString
  if s.startsWith(OboBase) then
    val local = s.substring(OboBase.length)
    val idx = local.indexOf('_')
    if idx > 0 then local.substring(0, idx) + ":" + local.substring(idx + 1)
    else local
  else s

// ---------------------------------------------------------------------------
// OntologyIndex — loads OBOs and provides entity lookup
// ---------------------------------------------------------------------------
class OntologyIndex(oboDir: os.Path, factory: OWLDataFactory):
  // Load each OBO file into its own manager to avoid ontology ID conflicts
  private val ontologies: Seq[OWLOntology] =
    val oboFiles = os.list(oboDir).filter(_.ext == "obo").sorted
    System.err.println(s"Loading ${oboFiles.size} ontology files from $oboDir ...")
    oboFiles.map { p =>
      System.err.print(s"  ${p.last} ... ")
      val mgr = OWLManager.createOWLOntologyManager()
      val ont = mgr.loadOntologyFromOntologyDocument(p.toIO)
      System.err.println(s"${ont.getClassesInSignature.size} classes, ${ont.getObjectPropertiesInSignature.size} properties")
      ont
    }

  // All classes and properties from loaded ontologies
  private val allClasses: Set[IRI] =
    ontologies.flatMap(_.getClassesInSignature.asScala.map(_.getIRI)).toSet

  private val allProperties: Set[IRI] =
    ontologies.flatMap(_.getObjectPropertiesInSignature.asScala.map(_.getIRI)).toSet ++
    KnownRelations.keys.map(curieToIRI).toSet

  // IRI -> set of rdfs:label values
  private val rdfsLabelIRI = IRI.create("http://www.w3.org/2000/01/rdf-schema#label")

  val iriToLabels: Map[IRI, Set[String]] =
    val m = mutable.Map[IRI, mutable.Set[String]]()
    for
      ont <- ontologies
      entity <- (ont.getClassesInSignature.asScala ++ ont.getObjectPropertiesInSignature.asScala)
      ax <- ont.getAnnotationAssertionAxioms(entity.getIRI).asScala
      if ax.getProperty.getIRI == rdfsLabelIRI
    do
      ax.getValue match
        case lit: OWLLiteral =>
          m.getOrElseUpdate(entity.getIRI, mutable.Set.empty) += lit.getLiteral
        case _ =>

    // Add known relation labels
    for (curie, label) <- KnownRelations do
      m.getOrElseUpdate(curieToIRI(curie), mutable.Set.empty) += label

    m.view.mapValues(_.toSet).toMap

  // Label -> set of IRIs (for label-based entity resolution)
  val labelToClassIris: Map[String, Set[IRI]] =
    val m = mutable.Map[String, mutable.Set[IRI]]()
    for
      (iri, labels) <- iriToLabels
      if allClasses.contains(iri)
      label <- labels
    do m.getOrElseUpdate(label, mutable.Set.empty) += iri
    m.view.mapValues(_.toSet).toMap

  val labelToPropertyIris: Map[String, Set[IRI]] =
    val m = mutable.Map[String, mutable.Set[IRI]]()
    for
      (iri, labels) <- iriToLabels
      if allProperties.contains(iri)
      label <- labels
    do m.getOrElseUpdate(label, mutable.Set.empty) += iri
    m.view.mapValues(_.toSet).toMap

  // Obsolete IRIs (owl:deprecated true)
  private val deprecatedIRI = OWLRDFVocabulary.OWL_DEPRECATED.getIRI

  val obsoleteIris: Set[IRI] =
    (for
      ont <- ontologies
      entity <- (ont.getClassesInSignature.asScala ++ ont.getObjectPropertiesInSignature.asScala)
      ax <- ont.getAnnotationAssertionAxioms(entity.getIRI).asScala
      if ax.getProperty.getIRI == deprecatedIRI
      if ax.getValue match
        case lit: OWLLiteral => lit.getLiteral == "true"
        case _ => false
    yield entity.getIRI).toSet

  // Relational quality IRIs (PATO terms in relational_slim subset)
  private val inSubsetIRI = IRI.create("http://www.geneontology.org/formats/oboInOwl#inSubset")

  val relationalQualityIris: Set[IRI] =
    (for
      ont <- ontologies
      cls <- ont.getClassesInSignature.asScala
      ax <- ont.getAnnotationAssertionAxioms(cls.getIRI).asScala
      if ax.getProperty.getIRI == inSubsetIRI
      if ax.getValue.toString.contains("relational_slim")
    yield cls.getIRI).toSet

  def hasClass(iri: IRI): Boolean = allClasses.contains(iri)
  def hasProperty(iri: IRI): Boolean = allProperties.contains(iri)
  def hasEntity(curie: String): Boolean =
    val iri = curieToIRI(curie)
    hasClass(iri) || hasProperty(iri)
  def getLabels(curie: String): Set[String] =
    iriToLabels.getOrElse(curieToIRI(curie), Set.empty)
  def isObsolete(curie: String): Boolean =
    obsoleteIris.contains(curieToIRI(curie))
  def isRelationalQuality(curie: String): Boolean =
    relationalQualityIris.contains(curieToIRI(curie))

  def summary: String =
    s"  ${allClasses.size} classes, ${allProperties.size} properties, " +
    s"${obsoleteIris.size} obsolete, ${relationalQualityIris.size} relational qualities\n" +
    s"  ${iriToLabels.size} entities with labels, ${labelToClassIris.size} class labels, ${labelToPropertyIris.size} property labels"

// ---------------------------------------------------------------------------
// Entity checkers for the Manchester parser
// ---------------------------------------------------------------------------

/** Resolves CURIEs like UBERON:0001424 to OWL entities */
class CurieEntityChecker(index: OntologyIndex, factory: OWLDataFactory) extends OWLEntityChecker:
  override def getOWLClass(name: String): OWLClass =
    val iri = curieToIRI(name)
    if index.hasClass(iri) then factory.getOWLClass(iri) else null

  override def getOWLObjectProperty(name: String): OWLObjectProperty =
    val iri = curieToIRI(name)
    if index.hasProperty(iri) then factory.getOWLObjectProperty(iri) else null

  override def getOWLDataProperty(name: String): OWLDataProperty = null
  override def getOWLIndividual(name: String): OWLNamedIndividual = null
  override def getOWLDatatype(name: String): OWLDatatype = null
  override def getOWLAnnotationProperty(name: String): OWLAnnotationProperty = null

/** Resolves labels like 'nasal bone' or part_of to OWL entities */
class LabelEntityChecker(index: OntologyIndex, factory: OWLDataFactory) extends OWLEntityChecker:
  // The ManchesterOWLSyntaxParserImpl in OWL API 4.5.x passes single-quoted names
  // to the entity checker WITH the quotes still attached. Strip them here.
  private def unquote(name: String): String =
    if name.length >= 2 && name.startsWith("'") && name.endsWith("'") then name.substring(1, name.length - 1)
    else name

  // When a label maps to multiple IRIs, prefer non-TEMP IRIs (real ontology terms)
  private def preferNonTemp(iris: Set[IRI]): Option[IRI] =
    val nonTemp = iris.filterNot(_.toString.contains("TEMP"))
    nonTemp.headOption.orElse(iris.headOption)

  override def getOWLClass(name: String): OWLClass =
    index.labelToClassIris.get(unquote(name)).flatMap(preferNonTemp).map(factory.getOWLClass).orNull

  override def getOWLObjectProperty(name: String): OWLObjectProperty =
    index.labelToPropertyIris.get(unquote(name)).flatMap(preferNonTemp).map(factory.getOWLObjectProperty).orNull

  override def getOWLDataProperty(name: String): OWLDataProperty = null
  override def getOWLIndividual(name: String): OWLNamedIndividual = null
  override def getOWLDatatype(name: String): OWLDatatype = null
  override def getOWLAnnotationProperty(name: String): OWLAnnotationProperty = null

// ---------------------------------------------------------------------------
// Manchester syntax parsing
// ---------------------------------------------------------------------------
def parseExpression(
  expression: String,
  checker: OWLEntityChecker,
  factory: OWLDataFactory
): Either[String, OWLClassExpression] =
  if expression.isBlank then return Right(factory.getOWLThing)
  try
    val configSupplier: java.util.function.Supplier[OWLOntologyLoaderConfiguration] =
      () => new OWLOntologyLoaderConfiguration()
    val parser = new ManchesterOWLSyntaxParserImpl(configSupplier, factory)
    parser.setOWLEntityChecker(checker)
    parser.setStringToParse(expression)
    Right(parser.parseClassExpression())
  catch
    case e: Exception => Left(e.getMessage)

// ---------------------------------------------------------------------------
// CURIE and label extraction for token-level comparison
// ---------------------------------------------------------------------------
val CuriePattern = """[A-Z_]+:[A-Za-z0-9_][A-Za-z0-9_-]*""".r

def extractCuries(expression: String): Seq[String] =
  if expression == null || expression.isBlank then Seq.empty
  else CuriePattern.findAllIn(expression).toSeq

// Extract labels from label expressions: single-quoted multi-word labels
// and unquoted single-word terms (excluding Manchester syntax keywords)
val ManchesterKeywords = Set("and", "or", "some", "only", "that", "inverse", "Self")

def extractLabels(expression: String): Seq[String] =
  if expression == null || expression.isBlank then Seq.empty
  else
    val labels = mutable.Buffer[String]()
    // Extract in left-to-right order: quoted labels and unquoted terms
    var pos = 0
    val s = expression
    while pos < s.length do
      if s(pos) == '\'' then
        // Quoted label
        val end = s.indexOf('\'', pos + 1)
        if end > pos then
          labels += s.substring(pos + 1, end)
          pos = end + 1
        else pos += 1
      else if s(pos) == '(' || s(pos) == ')' || s(pos).isWhitespace then
        pos += 1
      else
        // Unquoted word
        val end = s.indexWhere(c => c.isWhitespace || c == '(' || c == ')' || c == '\'', pos)
        val word = if end > pos then s.substring(pos, end) else s.substring(pos)
        pos = if end > pos then end else s.length
        // "not" followed by "some" is the label for PHENOSCAPE:complement_of
        if word == "not" then
          labels += word
        else if !ManchesterKeywords.contains(word) then
          labels += word
    labels.toSeq

/** Check that CURIEs and labels correspond pairwise (in extraction order). */
def checkCurieLabelCorrespondence(
  idExpr: String, labelExpr: String, index: OntologyIndex
): Seq[String] =
  val curies = extractCuries(idExpr)
  val labels = extractLabels(labelExpr)
  val errors = mutable.Buffer[String]()
  if curies.size != labels.size then
    errors += s"ID has ${curies.size} term(s) [${curies.mkString(", ")}] but label has ${labels.size} term(s) [${labels.mkString(", ")}]"
  else
    for (curie, label) <- curies.zip(labels) do
      val knownLabels = index.getLabels(curie)
      if knownLabels.nonEmpty && !knownLabels.contains(label) then
        errors += s"$curie has label(s) {${knownLabels.mkString(", ")}}, not '$label'"
  errors.toSeq

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------
case class Issue(file: String, line: Int, char: String, state: String, msg: String, isError: Boolean):
  def formatted: String =
    val tag = if isError then fansi.Color.Red("ERROR") else fansi.Color.Yellow("WARN ")
    s"$tag: $file:$line (char $char, state $state): $msg"

// Column indices (0-based)
val IdCols    = Seq(4, 6, 8)  // Entity ID, Quality ID, Related Entity ID
val LabelCols = Seq(5, 7, 9)  // Entity Label, Quality Label, Related Entity Label
val ColNames  = Seq("Entity", "Quality", "Related Entity")

val MagnitudeRelations = Set(
  "PATO:0002304", "PATO:0002305", "PATO:0002306",
  "increased_in_magnitude_relative_to",
  "decreased_in_magnitude_relative_to",
  "similar_in_magnitude_relative_to"
)

def validateFile(
  path:    os.Path,
  index:   OntologyIndex,
  factory: OWLDataFactory,
  curieChecker: CurieEntityChecker,
  labelChecker: LabelEntityChecker
): Seq[Issue] =
  val issues = mutable.Buffer[Issue]()
  val filename = path.last

  val lines = Try(os.read.lines(path)) match
    case Failure(e) =>
      return Seq(Issue(filename, 0, "-", "-", s"cannot read file: ${e.getMessage}", true))
    case Success(ls) => ls

  if lines.isEmpty then
    return Seq(Issue(filename, 0, "-", "-", "empty file", true))

  // Skip header and blank trailing lines
  for (line, lineIdx) <- lines.zipWithIndex.drop(1) if line.trim.nonEmpty do
    val lineNum = lineIdx + 1
    val cols = line.split("\t", -1)

    // Check 1: column count must be exactly 10
    if cols.length != 10 then
      issues += Issue(filename, lineNum, cols.lift(0).getOrElse("?"),
        cols.lift(2).getOrElse("?"),
        s"expected 10 columns, got ${cols.length}" +
          (if cols.length < 10 then " (ensure empty trailing columns have tab separators)" else ""),
        true)
    else
      val charNum  = cols(0)
      val stateSym = cols(2)

      for i <- 0 until 3 do
        val idExpr    = cols(IdCols(i)).trim
        val labelExpr = cols(LabelCols(i)).trim
        val colName   = ColNames(i)

        // Check 2: ID present but label missing (or vice versa)
        if idExpr.nonEmpty && labelExpr.isEmpty then
          issues += Issue(filename, lineNum, charNum, stateSym,
            s"$colName ID has value but label is empty: $idExpr", true)
        else if idExpr.isEmpty && labelExpr.nonEmpty then
          issues += Issue(filename, lineNum, charNum, stateSym,
            s"$colName label has value but ID is empty: $labelExpr", true)
        else if idExpr.nonEmpty && labelExpr.nonEmpty then
          // Simple CURIE checks (before attempting parse)
          val curies = extractCuries(idExpr)
          for curie <- curies do
            // Check 6: obsolete
            if index.isObsolete(curie) then
              val label = index.getLabels(curie).headOption.map(l => s" '$l'").getOrElse("")
              issues += Issue(filename, lineNum, charNum, stateSym,
                s"$colName uses obsolete term: $curie$label — find a replacement in the ontology", true)

          // Check 3: Parse ID expression (validates CURIEs exist and syntax)
          parseExpression(idExpr, curieChecker, factory) match
            case Left(err) =>
              // Truncate verbose parser output — first line has the key info
              val shortErr = err.linesIterator.next()
              issues += Issue(filename, lineNum, charNum, stateSym,
                s"$colName ID parse error ($idExpr): $shortErr", true)
            case Right(_) => // ID syntax OK

          // Check 4: Parse label expression (validates labels exist and syntax)
          // Preprocess: quote 'not' when used as PHENOSCAPE:complement_of label
          val preprocessedLabel = labelExpr.replaceAll("\\bnot\\b(?=\\s+some\\b)", "'not'")
          parseExpression(preprocessedLabel, labelChecker, factory) match
            case Left(err) =>
              val shortErr = err.linesIterator.next()
              issues += Issue(filename, lineNum, charNum, stateSym,
                s"$colName label parse error ($labelExpr): $shortErr", true)
            case Right(_) => // Label syntax OK

          // Check 5: CURIE/label correspondence (token-level)
          for err <- checkCurieLabelCorrespondence(idExpr, labelExpr, index) do
            issues += Issue(filename, lineNum, charNum, stateSym,
              s"$colName label mismatch: $err", true)

      // Check 7: Relational quality without Related Entity
      val qualityId = cols(6).trim
      val reId      = cols(8).trim
      val reLbl     = cols(9).trim
      if qualityId.nonEmpty then
        val topCurie = extractCuries(qualityId).headOption.getOrElse("")
        val qualityLabel = if topCurie.nonEmpty then index.getLabels(topCurie).headOption.map(l => s" '$l'").getOrElse("") else ""
        if topCurie.nonEmpty && index.isRelationalQuality(topCurie) &&
           reId.isEmpty && reLbl.isEmpty then
          issues += Issue(filename, lineNum, charNum, stateSym,
            s"relational quality $topCurie$qualityLabel requires a Related Entity (columns 9-10)", true)

        // Warning: non-relational quality with RE
        if topCurie.nonEmpty && !index.isRelationalQuality(topCurie) &&
           reId.nonEmpty then
          val hasMagnitude = MagnitudeRelations.exists(r => qualityId.contains(r))
          if !hasMagnitude then
            issues += Issue(filename, lineNum, charNum, stateSym,
              s"non-relational quality $topCurie$qualityLabel has Related Entity filled in — is this intentional?", false)

  issues.toSeq

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
@main def validate(args: String*): Unit =
  if args.isEmpty then
    System.err.println("Usage: scala-cli run validate_annotations.scala -- <file.tsv> [file2.tsv ...]")
    sys.exit(2)

  // Resolve ontology directory relative to script location
  val scriptFile = os.Path(sourcecode.File())
  val baseDir    = scriptFile / os.up / os.up  // scripts/ -> ai-annotation/
  val oboDir     = baseDir / "input" / "ontologies"

  val factory = OWLManager.getOWLDataFactory
  val index   = new OntologyIndex(oboDir, factory)
  System.err.println(index.summary)

  val curieChecker = new CurieEntityChecker(index, factory)
  val labelChecker = new LabelEntityChecker(index, factory)

  var totalErrors   = 0
  var totalWarnings = 0
  var filesWithErrors = 0
  val totalFiles = args.size

  for arg <- args do
    val path = os.Path(arg, os.pwd)
    val issues = validateFile(path, index, factory, curieChecker, labelChecker)
    val errors   = issues.count(_.isError)
    val warnings = issues.count(!_.isError)
    if errors > 0 then filesWithErrors += 1
    totalErrors += errors
    totalWarnings += warnings
    for issue <- issues do
      println(issue.formatted)

  println()
  print(s"Validated $totalFiles file(s): ")
  if totalErrors == 0 && totalWarnings == 0 then
    println(fansi.Color.Green("all OK").toString)
  else
    val parts = mutable.Buffer[String]()
    if totalErrors > 0 then
      parts += fansi.Color.Red(s"$totalErrors error(s) in $filesWithErrors file(s)").toString
    if totalWarnings > 0 then
      parts += fansi.Color.Yellow(s"$totalWarnings warning(s)").toString
    println(parts.mkString(", "))

  sys.exit(if totalErrors > 0 then 1 else 0)
