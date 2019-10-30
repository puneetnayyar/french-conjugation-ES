/*
* Puneet Nayyar
* 9/14/18
*
* validateToolbox.clp contains a collection of various validate functions, each of which build upon eachother
* for specific variations.
*/

/*
* validateString will check if the given parameter is a string
*/
(deffunction validateString (?s)
   (return (stringp ?s))
)

/*
* validateNumChar will check if the given parameter token has a length of ?n characters
*
* @precondition the parameter ?n must be an integer
*/
(deffunction validateNumChar (?s ?n)
   (return (= (str-length ?s) ?n))
)

/*
* validateNum will check if the given parameter is a number
*/
(deffunction validateNum (?n)
   (return (numberp ?n))
)

/*
* validateStringNumChar will check if the parameter ?s is a string and if the string has ?n characters
*/
(deffunction validateStringNumChar (?s ?n)
   (return (and (validateString ?s) (validateNumChar ?s ?n)))
)


/*
* validateStringMaxLength will check if the parameter ?s has more than ?n characters
*/
(deffunction validateStringOverLength (?s ?n)
   (return (> (str-length ?s) ?n))
)
