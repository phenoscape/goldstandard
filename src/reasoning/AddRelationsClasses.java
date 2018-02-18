package reasoning;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Set;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLAxiom;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLObjectProperty;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLOntologyStorageException;

public class AddRelationsClasses {
	public static void main(String[] args) throws OWLOntologyCreationException, OWLOntologyStorageException, IOException
	{
		
		
		File file=new File( "../../Ontologies/MergedOntology_GS.owl");
		File outputfile = new File("../../Ontologies/MergedOntology_GS_Relations.owl");
		String base="http://purl.obolibrary.org/obo/";
		
		OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
	    OWLDataFactory factory = manager.getOWLDataFactory();
	    String objectpropertyfile="../../data/PropertiesInData.txt";
	    
	    BufferedReader reader = null;
	    reader = new BufferedReader(new FileReader(objectpropertyfile));
	        String line = null;
	        OWLOntology ontology = manager.loadOntologyFromOntologyDocument(file);
    	    Set<OWLClass> classset = ontology.getClassesInSignature();
	        while ((line = reader.readLine()) != null) 
	        {
	    	    line=line.replace(":", "_");
	        	OWLObjectProperty property = factory.getOWLObjectProperty(IRI.create(base + line.trim()));
	    	    
	    	    for (OWLClass cls : classset) {
	    	    	
	    	    	String classname=""+cls;
	    	    	if (classname.contains("http://purl.obolibrary.org/obo/"))
	    	    	{
	    	    	classname=classname.split("http://purl.obolibrary.org/obo/")[1];
	    	    	classname=classname.replace(">","");
	    	    	if (!classname.contains("PATO") && !classname.contains("BSPO"))
	    	    	{
	    	    		OWLClassExpression partof = factory.getOWLObjectSomeValuesFrom(property,cls);
	    	    		 OWLClass NewClass = factory.getOWLClass(IRI.create(base + line.trim()+classname.trim()));
	    	 	        OWLAxiom phenotypeEquivalence = factory.getOWLEquivalentClassesAxiom(NewClass,
	    	 	                partof);
	    	 	       manager.addAxiom(ontology, phenotypeEquivalence);
	    	 	       
	    	    	}
	            }
	    	    }
	    	    
	        }
	        reader.close();
	        manager.saveOntology(ontology,
    			    IRI.create((outputfile)));	
	            

	}
}
