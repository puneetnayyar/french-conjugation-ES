import jess.*;

/*
 * Puneet Nayyar
 * 1/8/2018
 *
 * The FrenchConjugation class uses a simple implementation of the Rete Java class to translate
 * present tense French verbs. The main purpose of this class is to properly display the many different
 * accents used in the language. A thorough description of the actual expert system's functionality can be
 * found in the frenchConjugation.clp file that is actually used by the Rete engine.
 */
public class FrenchConjugation
{
   /*
    * The main method that creates a Rete object, batches in the .clp file containing all the methods and
    * rules used for the conjugation, and runs the inference engine.
    *
    * @param args arguments for the command line
    * @throws JessException if there are any compiling or runtime errors with the .clp file
    */
   public static void main(String[] args) throws JessException
   {
      Rete engine = new Rete();

      engine.eval("(clear)(reset)");
      engine.batch("C:\\Users\\Puneet\\Desktop\\Jess71p1\\Jess71p1\\bin\\frenchConjugation.clp");
      engine.eval("(run)");
   }
}
