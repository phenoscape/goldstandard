package reasoning;

import java.util.Set;

import org.semanticweb.owlapi.expression.ParserException;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.util.ShortFormProvider;

public class DLQueryPrinter {

    private final DLQueryEngine engine;
    private final ShortFormProvider shortFormProvider;

    public DLQueryPrinter(DLQueryEngine engine, ShortFormProvider shortFormProvider) {
        this.engine = engine;
        this.shortFormProvider = shortFormProvider;
    }

    public String askQuery(String classExpression) throws ParserException {
        if (classExpression == null || classExpression.trim().length() == 0) {
            return "";
        }
        Set<OWLClass> superClasses = engine.getSuperClasses(classExpression, false);
        StringBuilder sb = new StringBuilder();
        for (OWLClass cls : superClasses) {
            sb.append(",").append(cls);
        }
        return sb.toString();
    }
}
