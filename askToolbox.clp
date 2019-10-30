/*
* Puneet Nayyar
* 8/31/18
*
* askToolbox.clp contains various functions which serve the general purpose of prompting a user for information and retrieving the input
*/ 


/*
* The function ask takes in a parameter and will print it out in a question format, read the user input, and return the value
*/
(deffunction askQuestion (?prompt)		
	(return (askWithPunctuation ?prompt "?"))
)

/*
* The function prompt simply prints out a parameter prompt followed by a colon and returns the user input
*/
(deffunction askColon (?prompt)
	(return (askWithPunctuation ?prompt ":"))
)

/*
* The function askWithPunctuation will take in a prompt and an ending punctuation and ask the prompt with the punctuation
*/
(deffunction askWithPunctuation (?s ?p)
	(printout t ?s ?p " ")       ; Get user input with the prompt ?s and add the ending punctuation ?p
	(println)
	(return (read))
)

/*
* The function askWithoutPunctuation will take in a prompt and ask the prompt without punctuation
*/
(deffunction askWithoutPunctuation (?s)
	(printout t ?s)       		 ; Get user input with the prompt ?s
	(println)
	(return (read))
)

/*
* The function println takes in a list of prompts and will print them out consecutively and then print a new line.
*/
(deffunction println ($?args)
	(foreach ?text $?args (printout t ?text))
	(printout t crlf)
	(return)
)
