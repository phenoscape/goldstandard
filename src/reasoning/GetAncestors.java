package reasoning;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.io.PrintWriter;
import org.semanticweb.elk.owlapi.ElkReasonerFactory;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.expression.ParserException;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLOntologyStorageException;
import org.semanticweb.owlapi.reasoner.InferenceType;
import org.semanticweb.owlapi.reasoner.OWLReasoner;
import org.semanticweb.owlapi.reasoner.OWLReasonerFactory;
import org.semanticweb.owlapi.util.ShortFormProvider;
import org.semanticweb.owlapi.util.SimpleShortFormProvider;

public class GetAncestors 
{

	public static void main(String[] args) throws IOException, OWLOntologyStorageException, OWLOntologyCreationException,  ParserException, ClassNotFoundException, SQLException 
	{
		
		String databasename=args[0];
		String ontologyname=args[1];
		String annotationfile=args[2];
		String propertyfile=args[3];
		
		
		DbConnection dbconn=new DbConnection();
		Connection conn=dbconn.connection();
		//String propertyfile="/Users/pmanda/Documents/charaparser-evaluation-data/ontologies-from-Jim/PropertiesInData.txt";
	    
		
		
		
		AncestorsMethods methods = new AncestorsMethods();
		String base="http://purl.obolibrary.org/obo/";
		OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
	    OWLDataFactory factory = manager.getOWLDataFactory();
	    
	    BufferedReader prop = new BufferedReader(new FileReader(propertyfile));
		
	    List propertylist = new ArrayList();
	    String property;
		while ((property = prop.readLine()) != null)
	    {
	    propertylist.add(property.trim().replace(":","_"));	
	    }
		
	    File file = new File(ontologyname);
	    OWLOntology ontology = manager.loadOntologyFromOntologyDocument(file);
	    System.out.println("Loaded ontology: " + ontology);
	    OWLReasonerFactory reasonerFactory = new ElkReasonerFactory();
	    OWLReasoner reasoner = reasonerFactory.createReasoner(ontology);
	    ShortFormProvider shortFormProvider = new SimpleShortFormProvider();
        DLQueryPrinter dlQueryPrinter = new DLQueryPrinter(new DLQueryEngine(reasoner, 
        		shortFormProvider), shortFormProvider);
	    reasoner.precomputeInferences(InferenceType.CLASS_HIERARCHY); 
	    
		
		
		BufferedReader br = new BufferedReader(new FileReader(annotationfile));
	    String line;
	    List<String> ontologies = Arrays.asList("GO","GOTEMP", "CL","PR","UBPROP","CHEBI-LITE", "FMA", 
	    		"UBERON", "UBERONTEMP", "BSPOTEMP", "PATOTEMP", "PATO", "BSPO", "UNKNOWNTEMP");
	    List<String> ids = new ArrayList<String>();
	    List<String> nestedids=new ArrayList<String>();
	    String [] hangs={"PATO_0000070 and inheres_in some (UBERON_0017258)","PATO_0001997 and inheres_in some (UBERON_0010008)","PATO_0000470 and inheres_in some (UBERON_0010008)","PATOTEMP_2c9f9e29-141a-4967-aec3-202cf1773e52 and inheres_in some (UBERON_0010008)","PATOTEMP_a10fad4c-eac4-4098-b00a-2e1b9e449dba and inheres_in some (UBERON_0010008)","PATO_0000070 and inheres_in some (UBERON_0010008)"};
	    
	   while ((line = br.readLine()) != null)
	    {
		   
		   
		 if (!line.contains("Character"))
		 {
		   
		   if (!line.trim().contains("Entity ID"))
		   {
		   line = line.replace(":", "_");
	    	line = line.replace("\"", "");
	    	line=methods.sub(line);
			String [] terms = line.split("\t",-1);
		    String e1=terms[4];
		    String q1=terms[6];
		    String e2=terms[8];
		    
		    if (!e1.contains("null") && !q1.contains("null") && !e2.contains("null"))
		    {
	    	if (q1 !=null  && (q1.contains("RO_") || q1.contains("BSPO") || q1.contains("BFO") || 
	    			q1.contains("PHENOSCAPE")) && !(q1.contains("and") || 
	    			q1.contains("some")))
	    	{
	    		if (e2 !=null && !e2.trim().isEmpty())
	    		{
	    		e2 = q1+" some ("+e2+")";
	    		q1=null;
	    		}
	    	}
	    	System.out.println(e1+" "+q1+" "+e2);
		    String expression=methods.getExpression(e1,q1,e2,propertylist);
		    System.out.println("Expression is "+expression);
		    if (expression != null && !(Arrays.asList(hangs).contains(expression)))
		    {
		    String ancestors=methods.getExpressionAncestors(expression,dlQueryPrinter);
		    parseAncestor(ancestors,expression, conn, methods, databasename);
		    }
		    
		    
		    List<String> list = new ArrayList<String>();
		    list.add(e1);
		    list.add(q1);
		    list.add(e2);
			for ( String x: list )
			{
			  
				 System.out.println("x is "+x);
				 	if (x != null && !x.trim().isEmpty())
				 	{
			    	if (x.contains("and") || x.contains("some"))
			    	{
			    		nestedids.add(x);
			    	}
				 	}
			    
				if (x!=null && !x.trim().isEmpty())
				{
				if (x.contains("and"))
			    {
			    	x=x.replace("(", "");
			    	x=x.replace(")", "");
			    	String[] tempid = x.split("\\s+");
			    	for (String tmp: tempid)
			    	{
			    		String [] i = tmp.split("_");
			    	    String ID1= i[0];
			    		if (ontologies.contains(ID1)) 
						{
					        ids.add(tmp);
					    }
			    	}
			    }
			  
			    else
			    {
			    	   String [] temp = x.split("_");
					    String ID=temp[0];
						if (ontologies.contains(ID)) 
						{
					        ids.add(x);
					    }
			    }
			}
			 
			}
			
		   }
			
	    }
		   
		 } 
	    }
	   br.close();
			
       for (String classExpression: nestedids)
       {
           String ancestors= dlQueryPrinter.askQuery(classExpression.trim());
        	if (ancestors.trim().length() == 0 || ancestors.trim().equalsIgnoreCase(",owl:Thing"))
				{
        		System.out.println("No Ancestors Found"+ classExpression + "\t" +"\n");
        		
				}
        	
        	parseAncestor(ancestors,classExpression, conn, methods, databasename);
       }
	   
	   
	   
	   for (String id: ids)
			{
				id=id.trim();
				OWLClass clsA= factory.getOWLClass(IRI.create(base + id));
				String ancestors = methods.getancestors(clsA,reasoner);
				if (ancestors.trim().length() == 0 || ancestors.trim().equalsIgnoreCase(",owl:Thing"))
				{
					System.out.println("No Ancestors Found"+ clsA + "\t" +"\n");
				}
				
				parseAncestor(ancestors,id, conn, methods, databasename);
			
			}
		
	}
	   
		
	
    public static  void parseAncestor(String list, String classExpression, Connection conn,
    		AncestorsMethods methods, String databasename) throws SQLException 
    {
    	String [] temp=list.split(",");
     	classExpression=methods.reverseSub(classExpression);
			for (String anc: temp)
			{
				anc=anc.trim();
			
				if (anc.length() != 0 && !(anc.equalsIgnoreCase("owl:Thing")))
				{
					
					String [] anclist=anc.split("/obo/");
					String ancestor=anclist[1];
					ancestor=methods.reverseSub(ancestor);
					
				
					if (ancestor.length()!=0)
					{	
						ancestor=ancestor.replace(">","");
						System.out.println(classExpression+"  "+ancestor);
						String insertSQL = "INSERT IGNORE INTO " + databasename+ 
								" (term, ancestor) VALUES (?, ?)";
						PreparedStatement preparedStatement = conn.prepareStatement(insertSQL);preparedStatement.setString(1, classExpression);
						preparedStatement.setString(2, ancestor);
						preparedStatement.executeUpdate();
					
					}
				
				}			
			}
    }
}


