package reasoning;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
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
import org.semanticweb.owlapi.reasoner.NodeSet;
import org.semanticweb.owlapi.reasoner.OWLReasoner;
import org.semanticweb.owlapi.reasoner.OWLReasonerFactory;
import org.semanticweb.owlapi.util.ShortFormProvider;
import org.semanticweb.owlapi.util.SimpleShortFormProvider;

public class GetAncestors 
{

	public static void main(String[] args) throws IOException, OWLOntologyStorageException, OWLOntologyCreationException,  ParserException, ClassNotFoundException, SQLException 
	{
		
		String base="http://purl.obolibrary.org/obo/";
		OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
	    OWLDataFactory factory = manager.getOWLDataFactory();
	    String propertyfile="../data/PropertiesInData.txt";
	    ;
	    BufferedReader prop = new BufferedReader(new FileReader(propertyfile));
		
	    List propertylist = new ArrayList();
	    String property;
		while ((property = prop.readLine()) != null)
	    {
	    propertylist.add(property.trim().replace(":","_"));	
	    }
		File file = new File("../Ontologies/MergedOntology_GS_Relations.owl");
	    OWLOntology ontology = manager.loadOntologyFromOntologyDocument(file);
	    System.out.println("Loaded ontology: " + ontology);
	    OWLReasonerFactory reasonerFactory = new ElkReasonerFactory();
	    OWLReasoner reasoner = reasonerFactory.createReasoner(ontology);
	    ShortFormProvider shortFormProvider = new SimpleShortFormProvider();
        DLQueryPrinter dlQueryPrinter = new DLQueryPrinter(new DLQueryEngine(reasoner, 
        		shortFormProvider), shortFormProvider);
	    reasoner.precomputeInferences(InferenceType.CLASS_HIERARCHY); 
	    String outputfile="../data/AnnotationSubsumers_Relations.txt";
		PrintWriter printWriter = new PrintWriter (outputfile);
		String annotationfile="../data/AllAnnotations.tsv";
		BufferedReader br = new BufferedReader(new FileReader(annotationfile));
	    String line;
	    List<String> ontologies = Arrays.asList("GO","GOTEMP", "CL","PR","UBPROP","CHEBI-LITE", "CHEBI","FMA", 
	    		"UBERON", "UBERONTEMP", "BSPOTEMP", "PATOTEMP", "PATO", "BSPO", "UNKNOWNTEMP");
	    List<String> ids = new ArrayList<String>();
	    List<String> nestedids=new ArrayList<String>();
	    String [] hangs={"PATO_0000070 and inheres_in some (UBERON_0017258)","PATO_0001997 and inheres_in some (UBERON_0010008)","PATO_0000470 and inheres_in some (UBERON_0010008)","PATOTEMP_2c9f9e29-141a-4967-aec3-202cf1773e52 and inheres_in some (UBERON_0010008)","PATOTEMP_a10fad4c-eac4-4098-b00a-2e1b9e449dba and inheres_in some (UBERON_0010008)","PATO_0000070 and inheres_in some (UBERON_0010008)", "inheres_in some (UBERON_0017258)", "inheres_in some (UBERON_0010008)"};
		    
	   while ((line = br.readLine()) != null && !line.trim().contains("null"))
	    {
		   
		   if (!line.trim().contains("Entity ID"))
		   {
		   line = line.replace(":", "_");
	    	line = line.replace("\"", "");
	    	line=sub(line);
			String [] terms = line.split("\t",-1);
			String e1="";
			String q1="";
			String e2="";
			
			e1=terms[4];
			q1=terms[6];
			e2=terms[8];
		    String expression=getExpression(e1,q1,e2,propertylist);
		    
		    
		    List<String> list = new ArrayList<String>();
		    list.add(e1);
		    list.add(q1);
		    list.add(e2);
			for ( String x: list )
			{
			  
				 	if (x != null && !x.trim().isEmpty() && !(Arrays.asList(hangs).contains(x)))
				 	{
			    	if (x.contains("and") || x.contains("some"))
			    	{
			    		nestedids.add(x);
			    	}
				 	}
			    
				if (x!=null && !x.trim().isEmpty() && !(Arrays.asList(hangs).contains(expression)))
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
	   br.close();
			
       for (String classExpression: nestedids)
       {
           System.out.println("In nestedids");

           String ancestors= dlQueryPrinter.askQuery(classExpression.trim());
        	if (ancestors.trim().length() == 0 || ancestors.trim().equalsIgnoreCase(",owl:Thing"))
				{
        		System.out.println("No Ancestors Found"+ classExpression + "\t" +"\n");
        		
				}
        	
        	parseAncestor(ancestors,classExpression, printWriter);
       }
	   
	   
	   
	   for (String id: ids)
			{
				id=id.trim();
				OWLClass clsA= factory.getOWLClass(IRI.create(base + id));
				String ancestors = getancestors(clsA,reasoner);
				if (ancestors.trim().length() == 0 || ancestors.trim().equalsIgnoreCase(",owl:Thing"))
				{
					System.out.println("No Ancestors Found"+ clsA + "\t" +"\n");
				}
				
				parseAncestor(ancestors,id, printWriter);
			
			}
			printWriter.close();	
	}
	   
		
	
    public static  void parseAncestor(String list, String classExpression, PrintWriter printWriter) 
    {
    	String [] temp=list.split(",");
     	classExpression=reverseSub(classExpression);
			for (String anc: temp)
			{
				anc=anc.trim();
			
				if (anc.length() != 0 && !(anc.equalsIgnoreCase("owl:Thing")))
				{
					
					String [] anclist=anc.split("/obo/");
					String ancestor=anclist[1];
					ancestor=reverseSub(ancestor);
					
				
					if (ancestor.length()!=0)
					{	
						ancestor=ancestor.replace(">","");
						printWriter.println (classExpression+"\t"+ancestor);
					
					}
				
				}			
			}
    }
    
    /// Adding here
	public static String getancestors(OWLClass clsA, OWLReasoner reasoner) throws OWLOntologyCreationException
    {
    	String ancestorlist="";
    	NodeSet<OWLClass> subClses = reasoner.getSuperClasses(clsA, false);
        Set<OWLClass> clses = subClses.getFlattened();
        for (OWLClass cls : clses) {
            ancestorlist=ancestorlist+","+cls;
        }
        return(ancestorlist);
    }
	
	public static String getExpressionAncestors(String expression,reasoning.DLQueryPrinter dlQueryPrinter) throws SQLException, ParserException
	{
		  
		   String ancestors1="";
		    if (expression != null)
		    {	
		    ancestors1= dlQueryPrinter.askQuery(expression.trim());
		    if (ancestors1.trim().length() == 0 || ancestors1.trim().equalsIgnoreCase(",owl:Thing"))
			{
		    	System.out.println("No Ancestors Found"+ expression.trim() + "\t" +"\n");
		    	
			}
		    
		    
	}
		    return(ancestors1);
	}
	
    public static String getExpression(String E1, String Q1, String E2, List propertylist)
    {
    	if (E1 != null && E1.equals("Entity ID"))
    	{
    		return (null);
    	}
    	
    	String expression=null;
    	//if (Q1.trim() != null && Q1.trim().length()!=0)
    	
    	if (Q1!=null)
    	{
    		if (!Q1.trim().contains("null") && Q1.trim().length()!=0)
    		{
    		expression = Q1;
    		}
    	}
    	
    	
    	if (E1 !=null && E1.trim().length()!=0)
    	{
    		if (expression != null)
    		{
    			if(propertylist.contains(expression.trim()))
    			{
    				expression=expression+" some (inheres_in some ("+E1+"))";
    			}
    			else
    			{
    			expression=expression+" and inheres_in some ("+E1+")";
    			}
    		}
    		else
    		{
    			expression="inheres_in some ("+E1+")";
    		}
    	}
    	
    	if (E2 != null && E2.trim().length()!=0)
    	{
    		if (expression != null)
    		{
    			expression=expression+" and towards some ("+E2+")";
    		}
    		else
    		{
    			expression="towards some ("+E2+")";
    		}
    	}	

    	
    	return(expression);
    }

	

    
    public static  String reverseSub(String line)
	{
		
		
		
		line=line.replace("passes_through","BSPO_passes_through");
		line=line.replace("RO_0001025","OBO_REL_located_in");
		line=line.replace("UBREL_0000001","RO_0002150");
		line=line.replace("has_muscle_insertion","UBERON_has_muscle_insertion");
		line=line.replace("BSPO_0000126","UBERON_in_lateral_side_of");
		line=line.replace("has_muscle_origin","UBERON_has_muscle_origin");
		line=line.replace("encloses","UBERON_encloses");
		line=line.replace("attaches_to","UBERON_attaches_to");
		line=line.replace("connects","UBERON_connects");
		line=line.replace("BSPO_0000127","UBERON_in_median_plane_of");
		line=line.replace("posteriorly_connected_to","UBERON_posteriorly_connected_to");
		line=line.replace("anteriorly_connected_to","UBERON_anteriorly_connected_to");
		return(line);
	}
    
	public static  String sub(String line)
	{
	 	line=line.replace("BSPO_passes_through","passes_through");
		line=line.replace("OBO_REL_located_in","RO_0001025");
		line=line.replace("RO_0002150","UBREL_0000001");
		line=line.replace("UBERON_has_muscle_insertion","has_muscle_insertion");
		line=line.replace("UBERON_in_lateral_side_of","BSPO_0000126");
		line=line.replace("UBERON_has_muscle_origin","has_muscle_origin");
		line=line.replace("UBERON_encloses","encloses");
		line=line.replace("UBERON_attaches_to","attaches_to");
		line=line.replace("UBERON_connects","connects");
		line=line.replace("UBERON_in_median_plane_of","BSPO_0000127");
		line=line.replace("UBERON_posteriorly_connected_to","posteriorly_connected_to");
		line=line.replace("UBERON_anteriorly_connected_to","anteriorly_connected_to");
		return(line);
	}
}



