/*
* Puneet Nayyar
* 1/3/2019
* 
* frenchConjugation.clp contains a collection of functions and rules that together act as a learning tool to assist beginner French students in
* figuring out the correct conjugation of regular er, ir, and re verbs, as well as a large collection of irregular verbs. In addition, the tools 
* contains support for several special cases of verbs in between regular and irregular verbs, verbs which have slightly irregular conjugations 
* when used in certain ways (eg. manger, appeler). In essence, the tool functions by first asking the user whether they would like to read the 
* prompts in French or English, an important choice especially for extreme French novices who haven't yet mastered the reading of complicated 
* sentence structures and would prefer to read prompts in English. After the user has chosen their preferred language, the tool will then asks the
* user just two essential questions - the subject of the sentence and the regularity of the verb. These two questions will always be used, since 
* no matter what verb is being conjugated, the subject of the sentence is needed to find the correct conjugation. In addition, the regularity of the
* verb greatly affects the approach used to conjugate the verb. If a verb is regular, then only a fixed number of rules is needed to cover all 
* possible conjugations for that verb. Since there are three categories of regular verbs (er, ir, re) and six subjects (je, tu, il/elle/on, nous, 
* vous, ils/elles), every regular verb can be accounted for by eighteen rules. Irregular verbs, however, have absolutely no set rules for their 
* conjugations, so six rules (one for each subject) are needed for every different irregular verb. To avoid having to manually create six new rules
* for every irregular verb, the tool contains a buildIrregularRules function that takes in a verb with its six conjugations as parameters, and then 
* automatically creates the necessary rules for each verb. All of these rules use forward chaining to fire the approriate rules. In terms of user interface, 
* users respond to questions by choosing the choices from a numbered list, entering the number corresponding to their choice, and also have the option 
* to enter zero as an "I'm not sure" response. In the case that the user inputs zero, the system will take that as a signal that the user needs further 
* explanation. For asking the subject, regularity, and regular verb ending of a verb, inputting zero will prompt the tool to print a more detailed 
* explanation of what the user should look for in the sentence to appropriately answer the question. In the case of special, nonregular, nonirregular 
* verbs, the tool uses backward chaining to ask the user futher questions. For example, the user chooses -er for verb ending and nous for the subject, 
* the system will also ask the user if their verb falls in the special -ger ending category. If yes, the system will alter the conjugation. In terms of 
* actually conjugating verbs, the tool uses all the regular verb rules and irregular verb rules to choose the appropriate conjugated ending. In the final 
* rule fired in the system, the tool will use a function to strip the user's verb of its inifinitive root and then add on the proper conjugated root, 
* returning that combined verb as the final result. 
*
* An example usage of the tool would run as follows: 
* 1. The system asks the preferred language, the user chooses French
* 2. The system asks if the user's verb is regular, the user says yes
* 3. The system asks what the infinitive regular ending of the verb is, the user says I dont know
* 4. The system explains to the user how to find the infinitive ending of a verb and asks the question again, the user chooses -er
* 5. The system asks what the subject of the sentence is, the user chooses nous
* 6. The system asks what if the -er verb has the special -ger ending, the user chooses yes
* 7. The system asks the user to input their verb, the user inputs nager
* 8. The system returns the conjugated form of the verb, nageons, and exits
*/

(batch C:\\Users\\Puneet\\Desktop\\Jess71p1\\Jess71p1\\bin\\toolbox.clp) ; A toolbox containing commonly used functions

                                                                         ; A new line character used in formatting prompts
(defglobal ?*newLine* = "
")

(defglobal ?*REGULAR_ENDING_LENGTH* = 2)                                 ; The conventional ending length of all french regular verbs is two, so 
                                                                         ; this constant is used in stripping infinitive endings.

(defglobal ?*MIN_VERB_LENGTH* = 3)                                       ; The verb which the user submits must be be at least 3 characters.

/*
* A list of all the prompts used throughout the functioning of the tool. These are the English versions 
* and are used as the default prompts for the system
*/
(defglobal ?*startingLanguagePrompt* = "In what language would you like to view this tool's prompts?")
(defglobal ?*introductionPrompt* = (str-cat "Welcome, this tool provides support for the conjugation of French present tense verbs. To properly utilize " ?*newLine* 
                                            "this tool, you should have a basic understanding of how French verbs are conjugated. If you are ever " ?*newLine* 
                                            " unsure about a question asked, the tool will assist you by providing further explanation."))
(defglobal ?*enterIntegerValuePrompt* = "Please respond with the number corresponding to your choice, or 0 if you are unsure: ")
(defglobal ?*invalidInputPrompt* = "Invalid input. Please enter the integer value corresponding to your chosen response from the list, or 0 if you are unsure.")
(defglobal ?*askSubjectPrompt* = "What is the subject of the sentence?")
(defglobal ?*askRegularityPrompt* = "Is the verb that you are conjugating a regular verb?")
(defglobal ?*yesNoList* = (create$ Yes No))
(defglobal ?*askRegularEndingPrompt* = "What is the regular infinitive ending of the verb you are conjugating?")
(defglobal ?*invalidFreeInput* = "Invalid input. The verb must be a token matching the regularity/endings you previously indicated.")
(defglobal ?*askVerb* = "Please input the verb that you would like to conjugate in a token format")
(defglobal ?*successPromptPt1* = "The conjugated form of the verb ")
(defglobal ?*successPromptPt2* = " that you should use is ")
(defglobal ?*failurePrompt* = "Unfortunately, I do not know the correct conjugation for the verb ")
(defglobal ?*endingGerPrompt* = "Does the -er verb also have a 'g' preceding the ending, making the ending -ger?")
(defglobal ?*endingLerPrompt* = "Does the -er verb also have a 'l' preceding the ending, making the ending -ler?")
(defglobal ?*subjectUnknownPrompt* = (str-cat "If you are having trouble identifying the subject of the sentence, try to find out who or what " ?*newLine* 
                                              "is performing the action of the verb. If none of the subjects in the list show up in your sentence, " ?*newLine*
                                              "it may be because the subject is an actual noun or name. In general, nouns and single names are " ?*newLine*
                                              "replaced by Il/Elle/On, a combination of nouns/names and moi is replaced by Nous, a combination of  " ?*newLine*
                                              "nouns/names and toi is replaced by Vous, and groups of nouns/names are replaced by Ils/Elles. Try " ?*newLine*
                                              "your best to choose which of the pronouns in the list would make the most sense when replacing the " ?*newLine*
                                              "nouns/names in the sentence."))
(defglobal ?*regularUnknownPrompt* = (str-cat "If you are unsure whether your verb is regular, there isn't too much I can help you with. Generally, if" ?*newLine* 
                                              "a verb ends in -er, -ir, or -re, it's regular, but there are countless exceptions to this rule. You will " ?*newLine*
                                              "gain a better idea of which verbs are irregular by simply learning the French language, but as the name " ?*newLine*
                                              "implies, irregular verbs are completely irregular in their usage and conjugations, so there is no " ?*newLine*
                                              "foolproof way to identify one besides experience."))
(defglobal ?*endingUnknownPrompt* = (str-cat "If you are having trouble identifying the infinitive verb ending, simply look at the last two characters " ?*newLine* 
                                             "of your verb. If the last two characters are not er, ir, or re, then your verb is irregular."))
(defglobal ?*endingGerUnknownPrompt* = (str-cat "If you are having trouble identifying the -ger verb ending, simply look at the last three characters " ?*newLine* 
                                                "of your verb. If the last three characters are -ger, answer yes."))
(defglobal ?*endingLerUnknownPrompt* = (str-cat "If you are having trouble identifying the -ler verb ending, simply look at the last three characters " ?*newLine* 
                                                "of your verb. If the last three characters are -ler, answer yes."))

(do-backward-chaining endingGer)         ; A special verb case that is backward chained with the nous form of -er verbs
(do-backward-chaining endingLer)         ; A special verb case that is backward chained with the je, tu, il/elle, and ils/elles form of -er verbs

/*
* The function play clears and resets all the previously asserted facts and rules, rebatches in the file, and runs the inference engine
*/
(deffunction play ()
   (clear) (reset) 
   (batch C:\\Users\\Puneet\\Desktop\\Jess71p1\\Jess71p1\\bin\\frenchConjugation.clp)

   (run)
   (return)
)

/*
* askQuestionWithList takes in a question and a list of options and will create a string containing the question followed by a 
* numbered list of all the options. The function then uses askWithoutPunctuation to actually get the user response and returns it.
*/
(deffunction askQuestionWithList (?question ?options)
   (bind ?questionWithList ?question)

   (for (bind ?i 1) (<= ?i (length$ ?options)) (++ ?i)                                             ; Add the numbered list to the question
      (bind ?questionWithList (str-cat ?questionWithList ?*newLine* ?i ". " (nth$ ?i ?options)))   ; Uses nth$ to get the appropriate tokens from the options list
   )

   (bind ?questionWithList (str-cat ?questionWithList ?*newLine*))
   (bind ?questionWithList (str-cat ?questionWithList ?*enterIntegerValuePrompt*))
   (return (askWithoutPunctuation ?questionWithList))
)

/*
* validateListResponse takes in a user input and the options list which they chose the input from and makes sure that the user input 
* is within the range of the option list's length
*/
(deffunction validateListResponse (?input ?options)
   (return (and (integerp ?input) (>= ?input 0) (<= ?input (length$ ?options))))
)

/*
* askList takes in a question and options list and continues to ask the question with askQuestionWithList until the
* user's response is valid. Once validated, the user response is returned. 
*/
(deffunction askList (?question ?options)
   (bind ?input (askQuestionWithList ?question ?options))

   (while (not (validateListResponse ?input ?options)) do
      (println ?*invalidInputPrompt*)
      (bind ?input (askQuestionWithList ?question ?options))
   )

   (return (nth$ ?input ?options))  ; Uses $nth to convert the user's number response into the corresponding list value
)

/*
* makeListAssertion takes in a fact name, a question, and an options list and gets the users choice from the list with askList,
* and then asserts the fact with the user input
*
* Ex. (assert (subject nous))
*/
(deffunction makeListAssertion (?fact ?question ?options)
   (bind ?response (askList ?question ?options))

   (assert-string (str-cat "(" ?fact " " ?response ")"))

   (return)
)

/*
* validateCheckedReponse validates a token input by checking if it is a token and is also over three characters
* This prevents the user from inputting integers and invalid tokens when they are prompted to input the verb.
* The function also checks whether the input matches the user's given verb ending. The integer 1 used in the substring
* method is used to get the last two characters of the infinitive verb. 
*/
(deffunction validateCheckedResponse (?input ?check)
   (bind ?validString (and (lexemep ?input) (> (str-length ?input) ?*MIN_VERB_LENGTH*)))

   (return (and ?validString (= (sub-string (- (str-length ?input) 1) (str-length ?input) ?input) ?check)))
)

/*
* askCheckedResponse takes a questoin and gets the user's response with askColon, continually asking the question until the user's
* response is valid, agreeing with the ?check verb ending parameter, return the response at that point. 
*/
(deffunction askCheckedResponse (?question ?check)
   (bind ?input (askColon ?question))

   (while (not (validateCheckedResponse ?input ?check)) do
      (println ?*invalidFreeInput*)
      (bind ?input (askColon ?question))
   )

   (return (lowcase ?input))
)

/*
* makeCheckedAssertion takes in a fact name and a question and asserts the given fact with the user response from askFreeResponse.
* The ?check parameter is also used to make sure the user's response mathces a certain verb ending
* 
* Ex. (assert (verb nager))
*/
(deffunction makeCheckedAssertion (?fact ?question ?check)
   (bind ?response (askCheckedResponse ?question ?check))

   (assert-string (str-cat "(" ?fact " " ?response ")"))

   (return)
)

/*
* validateFreeReponse validates a token input by checking if it is a token and is also over three characters
* This prevents the user from inputting integers and invalid tokens when they are prompted to input the verb.
*/
(deffunction validateFreeResponse (?input)
   (return (and (lexemep ?input) (> (str-length ?input) ?*MIN_VERB_LENGTH*)))
)

/*
* askFreeResponse takes a questoin and gets the user's response with askColon, continually asking the question until the user's
* response is valid, returning the response at that point. 
*/
(deffunction askFreeResponse (?question)
   (bind ?input (askColon ?question))

   (while (not (validateFreeResponse ?input)) do
      (println ?*invalidFreeInput*)
      (bind ?input (askColon ?question))
   )

   (return (lowcase ?input))
)

/*
* makeFreeAssertion takes in a fact name and a question and asserts the given fact with the user response from askFreeResponse.
* 
* Ex. (assert (verb nager))
*/
(deffunction makeFreeAssertion (?fact ?question)
   (bind ?response (askFreeResponse ?question))

   (assert-string (str-cat "(" ?fact " " ?response ")"))

   (return)
)

/*
* stripEnding takes an infinitive verb and returns the "stripped" version of the verb, removing the last two characters
* of the infinitive- er, ir, or re.
*/
(deffunction stripEnding (?verb)
   (return (sub-string 1 (- (str-length ?verb) ?*REGULAR_ENDING_LENGTH*) ?verb))
)

/*
* Builds the irregular verb rules for an irregular verb, creating six rules, one for each subject.
*
* Example:
*  (defrule irregularAllerJe
*     (or (regular No) (regular Non))
*     (subject Je)
*     (verb aller)
*  =>
*     (assert (irregularConjugation vais))
*  )
*/
(deffunction buildIrregularVerbRules (?verb ?jeForm ?tuForm ?ilElleOnForm ?nousForm ?vousForm ?ilsEllesForm)
   (bind ?irregularRule (str-cat 
      "(defrule irregular" ?verb "Je (or (regular No) (regular Non)) (subject Je) (verb " ?verb ") => (assert (irregularConjugation " ?jeForm "))) "
      "(defrule irregular" ?verb "Tu (or (regular No) (regular Non)) (subject Tu) (verb " ?verb ") => (assert (irregularConjugation " ?tuForm "))) "
      "(defrule irregular" ?verb "IlElleOn (or (regular No) (regular Non)) (subject Il/Elle/On) (verb " ?verb ") => (assert (irregularConjugation " ?ilElleOnForm "))) "
      "(defrule irregular" ?verb "Nous (or (regular No) (regular Non)) (subject Nous) (verb " ?verb ") => (assert (irregularConjugation " ?nousForm "))) "
      "(defrule irregular" ?verb "Vous (or (regular No) (regular Non)) (subject Vous) (verb " ?verb ") => (assert (irregularConjugation " ?vousForm "))) "
      "(defrule irregular" ?verb "IlsElles (or (regular No) (regular Non)) (subject Ils/Elles) (verb " ?verb ") => (assert (irregularConjugation " ?ilsEllesForm ")))")
   )

   (build ?irregularRule)
   (return)
)

(defrule chooseLanguage "The first rule fired in the system, and it prompts the user to chooses a language, English or French, to view the prompts."
   (declare (salience 100))
=>
   (makeListAssertion language ?*startingLanguagePrompt* (create$ French English))
)

(defrule setPromptsFrench "If the user chose French as their preferred language, the global message prompts are changed to their French counterparts,
                           and two additional facts are asserted to begin asking the user for the sentence components."
   (language French)
=>
   (bind ?*startingLanguagePrompt* "Dans quelle langue aimeriez-vous voir les invites de cet outil?")
   (bind ?*introductionPrompt* (str-cat "Bienvenue, cet outil soutient la conjugaison des verbes français presents. Pour bien utiliser cet outil, vous" ?*newLine* 
                                        "devriez avoir une compréhension de base de la façon dont les verbes français sont conjugués. Si jamais" ?*newLine* 
                                        "vous n’êtes pas sûr d’une question posée, l’outil vous aidera en fournissant des explications supplémentaires."))
   (bind ?*enterIntegerValuePrompt* "S'il vous plaît, répondre avec le numéro correspondant à votre choix, ou 0 si vous n'êtes pas sûr: ")
   (bind ?*invalidInputPrompt* "Entrée invalide. Entrez la valeur entière correspondant à votre réponse choisie dans la liste, ou 0 si vous n'êtes pas sûr.")
   (bind ?*askSubjectPrompt* "Quel est le sujet de la sentence?")
   (bind ?*askRegularityPrompt* "Le verbe que vous conjuguez, est-il un verbe régulier?")
   (bind ?*yesNoList* (create$ Oui Non))
   (bind ?*askRegularEndingPrompt* "Quelle est la fin infinitive régulière du verbe que vous conjuguez?")
   (bind ?*invalidFreeInput* "Entrée invalide. Le verbe doit correspondre à la régularité/terminaison que vous avez indiquée précédemment.")
   (bind ?*askVerb* "S'il vous plaît, entrer le verbe que vous souhaitez conjuguer dans un format jeton")
   (bind ?*successPromptPt1* "La forme conjuguée du verbe ")
   (bind ?*successPromptPt2* " que vous devriez utiliser est ")
   (bind ?*failurePrompt* "Malheureusement, je ne connais pas la conjugaison correcte pour le verbe ")
   (bind ?*endingGerPrompt* "Le verbe -er, y-a-t-il aussi un 'g' qui précède la fin, faisant le -ger final?")
   (bind ?*endingLerPrompt* "Le verbe -er, y-a-t-il aussi un 'l' qui précède la fin, faisant le -ler final?")
   (bind ?*subjectUnknownPrompt* (str-cat "Si vous avez de la difficulté à identifier le sujet de la peine, essayez de savoir qui ou ce qui exécute " ?*newLine* 
                                          "l’action du verbe. Si aucun des sujets de la liste n’apparaît dans votre phrase, c’est peut-être parce que " ?*newLine*
                                          "le sujet est un nom ou un nom. En général, les noms et les noms uniques sont remplacés par Il/Elle/On, une " ?*newLine*
                                          "combinaison de noms/noms et moi est remplacée par Nous, une combinaison de noms/noms et toi est remplacée " ?*newLine*
                                          "par Vous, et des groupes de noms/noms sont remplacés par Ils/Elles. Essayez de faire de votre mieux pour " ?*newLine*
                                          "choisir lequel des pronoms de la liste serait le plus logique au moment de remplacer les noms/noms dans la phrase."))
   (bind ?*regularUnknownPrompt* (str-cat "Si vous ne savez pas si votre verbe est régulier, je ne peux pas vous aider. Généralement, si un verbe " ?*newLine* 
                                          "se termine en -er, -ir, ou -re, c’est régulier, mais il y a d’innombrables exceptions à cette règle. Vous " ?*newLine*
                                          "aurez une meilleure idée des verbes qui sont irréguliers en apprenant simplement la langue française, mais " ?*newLine*
                                          "comme le nom l’indique, les verbes irréguliers sont complètement irrégulière dans leur utilisation et les " ?*newLine*
                                          "conjugaisons, il n’y a donc pas de moyen infaillible d’en identifier un en dehors de l’expérience."))
   (bind ?*endingUnknownPrompt*  (str-cat "Si vous avez de la difficulté à identifier la fin du verbe infinitif, il suffit de regarder les deux derniers " ?*newLine* 
                                          "caractères de votre verbe. Si les deux derniers caractères ne sont pas er, ir, ou re, alors votre verbe est irrégulier."))
   (bind ?*endingGerUnknownPrompt* (str-cat "Si vous avez du mal à identifier la fin du verbe -ger, regardez simplement les trois derniers caractères " ?*newLine* 
                                            "de votre verbe. Si les trois derniers caractères sont -ger, répondez oui."))
   (bind ?*endingLerUnknownPrompt* (str-cat "Si vous avez du mal à identifier la fin du verbe -ler, regardez simplement les trois derniers caractères " ?*newLine* 
                                            "de votre verbe. Si les trois derniers caractères sont -ler, répondez oui."))

   (assert (languageSet))
   (assert (needSubject))
   (assert (needRegular))
   (println ?*introductionPrompt*)
)

(defrule setPromptsEnglish "setPromptsEnglish does not change the prompts, since they are English by default, but it also asserts 
                           the two rules needed to ask for the subject and regularity."
   (language ?l &~French)
=>
   (assert (languageSet))
   (assert (needSubject))
   (assert (needRegular))
   (println ?*introductionPrompt*)
)

(defrule askSubject "askSubject simply uses makeListAssertion to ask the user to choose the subject of the sentence."
   (languageSet)
   (needSubject)
=>
   (makeListAssertion subject ?*askSubjectPrompt* (create$ Je Tu Il/Elle/On Nous Vous Ils/Elles))
)

(defrule askRegularity "askRegularity simply asks the user whether their verb is regular or not with makeListAssertion."
   (languageSet)
   (needRegular)
=>
   (makeListAssertion regular ?*askRegularityPrompt* ?*yesNoList*)
)

(defrule askRegularVerb "askRegularVerb simply asks the user to input their regular verb with makeCheckedAssertion"
   (languageSet)
   (regularEnding ?e)
   (subject ?s &~nil)
=>
   (makeCheckedAssertion verb ?*askVerb* ?e)
)

(defrule askIrregularVerb "askIrregularVerb simply asks the user to input their verb with makeFreeAssertion"
   (languageSet)
   (or (regular No) (regular Non))
   (subject ?s &~nil)
=>
   (makeFreeAssertion verb ?*askVerb*)
)

(defrule askRegularEndings "If the user has indicated their verb is regular, askRegularEndings will ask the user for its ending."
   (languageSet)
   (or (regular Yes) (regular Oui))
=>
   (makeListAssertion regularEnding ?*askRegularEndingPrompt* (create$ er ir re))
)

(defrule conjugateRegular "conjugateRegular combines the stripped verb with its conjugated ending and asserts the conjugated verb."
   (or (regular Yes) (regular Oui))
   (conjugatedEnding ?e)
   (verb ?v)
=>
   (bind ?strippedWithEnding (str-cat (stripEnding ?v) ?e))
   (assert (conjugatedVerb ?strippedWithEnding))
)

(defrule conjugateIrregular "conjugateIrregular just asserts the conjugated verb asserted from the irregular verb's specific rule."
   (or (regular No) (regular Non))
   (irregularConjugation ?irregular)
=>
   (assert (conjugatedVerb ?irregular))
)

(defrule endConjugationSuccessful "The final rule fired in the system, prints out the original verb and its conjugation with an ending message."
   (verb ?v)
   (conjugatedVerb ?c)
=>
   (println ?*successPromptPt1* ?v ?*successPromptPt2* ?c ".")
   (assert (finished))
)

(defrule endConjugationFailure "The final rule if the system couldn't figure out the correct conjugation, gives an ending give up message."
   (declare (salience -100))
   (not (finished))
   (verb ?v)
=>
   (println ?*failurePrompt* ?v ".")
)

(defrule unknownSubject "If the user didn't know the subject, print out a futher explanation, retract the currently asserted subject facts,
                         and reassert needSubject so the system asks for the subject again."
   ?f1 <- (subject nil)
   ?f2 <- (needSubject)
=>
   (retract ?f1)
   (retract ?f2)
   (println ?*subjectUnknownPrompt*)
   (assert (needSubject))
)

(defrule unknownRegular "If the user didn't know the regularity, print out a futher explanation, retract the currently asserted regularity facts,
                         and reassert needRegular so the system asks for the regularity again."
   ?f1 <- (regular nil)
   ?f2 <- (needRegular)
=>
   (retract ?f1)
   (retract ?f2)
   (println ?*regularUnknownPrompt*)
   (assert (needRegular))
)

(defrule unknownEnding "If the user didn't know the ending, print out a futher explanation, retract the currently asserted ending facts,
                        and reassert (regular ?r) so the system asks for the ending again."
   ?f1 <- (regularEnding nil)
   ?f2 <- (regular ?r)
=>
   (retract ?f1)
   (retract ?f2)
   (println ?*endingUnknownPrompt*)
   (assert ?f2)
)

(defrule unknownEndingGer "If the user didn't know the special ending -ger, print out a futher explanation, retract the currently asserted ending facts,
                           and reassert (regularEnding er) so the system asks for the special ending -ger again."
   ?f1 <- (regularEnding er)
   ?f2 <- (endingGer nil)
=>
   (retract ?f1)
   (retract ?f2)
   (println ?*endingGerUnknownPrompt*)
   (assert ?f1)
)

(defrule unknownEndingLer "If the user didn't know the special ending ler, print out a futher explanation, retract the currently asserted ending facts,
                           and reassert (regularEnding er) so the system asks for the special ending -ler again."
   ?f1 <- (regularEnding er)
   ?f2 <- (endingLer nil)
=>
   (retract ?f1)
   (retract ?f2)
   (println ?*endingLerUnknownPrompt*)
   (assert ?f1)
)

/*
* The two rules below implement the backward chaining funcionality for the "special case" nonirregular and nonregular verbs. 
* Both of these are special -er cases, where the ending has an extra letter that affects conjugation. The rules use makeListAssertion
* to ask the user whether or not they fall in the special case.
*/

(defrule gerBackward
   (need-endingGer ?)
   (subject Nous)
=>
   (makeListAssertion endingGer ?*endingGerPrompt* ?*yesNoList*)
)

(defrule lerBackward
   (need-endingLer ?)
   (or  (subject Je) (subject Tu) (subject Il/Elle/On) (subject Ils/Elles))
=>
   (makeListAssertion endingLer ?*endingLerPrompt* ?*yesNoList*)
)

/*
* The following rules provide coverage for the special case -er verbs, specifically -ger and -ler verbs. For -ger verbs,
* a special ending is required only if the user has chosen (subject nous), while for -ler verbs, special conjugations are required for
* Je, Tu, Il/Elle/On, and Ils/Elles. These rules require the (regularEnding er), the appropriate subject, and also the backward chained
* endingGer or endingLer facts. 
*/
(defrule regularGerNous
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Nous)
   (endingGer ?g &~No &~Non &~nil)
=>
   (assert (conjugatedEnding eons))
)

(defrule regularLerJe
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Je)
   (endingLer ?l &~No &~Non &~nil)
=>
   (assert (conjugatedEnding le))
)

(defrule regularLerTu
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Tu)
   (endingLer ?l &~No &~Non &~nil)
=>
   (assert (conjugatedEnding les))
)

(defrule regularLerIlElleOn
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Il/Elle/On)
   (endingLer ?l &~No &~Non &~nil)
=>
   (assert (conjugatedEnding le))
)

(defrule regularLerIlsElles
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Ils/Elles)
   (endingLer ?l &~No &~Non &~nil)
=>
   (assert (conjugatedEnding lent))
)

/*
* These are the rules used to get the conjugated endings for regular -ER verbs. Each rule requires both a verb ending, in this case
* er, as well as a subject, like Je, Tu, Il/Elle/On, etc. When one of these rules fires, it asserts a conjugatedEnding fact,
* whose value is the actual ending which will be appended to the "stripped" root later on. 
* 
* Notice that for these -er rules, as opposed to the -ir and -re rules, have additional conditions to fire, like 
* (endingLer ?l &~Yes &~Oui), or (endingGer ?g &~Yes &~Oui). These patterns account for the special case -er verbs,
* making sure that if the user has an -er verb, the system will first make sure it isn't a special case before conjugating.
*/

(defrule regularErJe
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Je)
   (endingLer ?l &~Yes &~Oui &~nil)
=>
   (assert (conjugatedEnding e))
)

(defrule regularErTu
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Tu)
   (endingLer ?l &~Yes &~Oui &~nil)
=>
   (assert (conjugatedEnding es))
)

(defrule regularErIlElleOn
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Il/Elle/On)
   (endingLer ?l &~Yes &~Oui &~nil)
=>
   (assert (conjugatedEnding e))
)

(defrule regularErNous
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Nous)
   (endingGer ?g &~Yes &~Oui &~nil)
=>
   (assert (conjugatedEnding ons))
)

(defrule regularErVous
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Vous)
=>
   (assert (conjugatedEnding ez))
)

(defrule regularErIlsElles
   (or (regular Yes) (regular Oui))
   (regularEnding er)
   (subject Ils/Elles)
   (endingLer ?l &~Yes &~Oui &~nil)
=>
   (assert (conjugatedEnding ent))
)

/*
* These are the rules used to get the conjugated endings for regular -IR verbs. Each rule requires both a verb ending, in this case
* ir, as well as a subject, like Je, Tu, Il/Elle/On, etc. When one of these rules fires, it asserts a conjugatedEnding fact,
* whose value is the actual ending which will be appended to the "stripped" root later on.
*/

(defrule regularIrJe
   (or (regular Yes) (regular Oui))
   (regularEnding ir)
   (subject Je)
=>
   (assert (conjugatedEnding is))
)

(defrule regularIrTu
   (or (regular Yes) (regular Oui))
   (regularEnding ir)
   (subject Tu)
=>
   (assert (conjugatedEnding is))
)

(defrule regularIrIlElleOn
   (or (regular Yes) (regular Oui))
   (regularEnding ir)
   (subject Il/Elle/On)
=>
   (assert (conjugatedEnding it))
)

(defrule regularIrNous
   (or (regular Yes) (regular Oui))
   (regularEnding ir)
   (subject Nous)
=>
   (assert (conjugatedEnding issons))
)

(defrule regularIrVous
   (or (regular Yes) (regular Oui))
   (regularEnding ir)
   (subject Vous)
=>
   (assert (conjugatedEnding issez))
)

(defrule regularIrIlsElles
   (or (regular Yes) (regular Oui))
   (regularEnding ir)
   (subject Ils/Elles)
=>
   (assert (conjugatedEnding issent))
)

/*
* These are the rules used to get the conjugated endings for regular -RE verbs. Each rule requires both a verb ending, in this case
* re, as well as a subject, like Je, Tu, Il/Elle/On, etc. When one of these rules fires, it asserts a conjugatedEnding fact,
* whose value is the actual ending which will be appended to the "stripped" root later on.
*/

(defrule regularReJe
   (or (regular Yes) (regular Oui))
   (regularEnding re)
   (subject Je)
=>
   (assert (conjugatedEnding s))
)

(defrule regularReTu
   (or (regular Yes) (regular Oui))
   (regularEnding re)
   (subject Tu)
=>
   (assert (conjugatedEnding s))
)

(defrule regularReIlElleOn
   (or (regular Yes) (regular Oui))
   (regularEnding re)
   (subject Il/Elle/On)
=>
   (assert (conjugatedEnding ""))
)

(defrule regularReNous
   (or (regular Yes) (regular Oui))
   (regularEnding re)
   (subject Nous)
=>
   (assert (conjugatedEnding ons))
)

(defrule regularReVous
   (or (regular Yes) (regular Oui))
   (regularEnding re)
   (subject Vous)
=>
   (assert (conjugatedEnding ez))
)

(defrule regularReIlsElles
   (or (regular Yes) (regular Oui))
   (regularEnding re)
   (subject Ils/Elles)
=>
   (assert (conjugatedEnding ent))
)

/*
* Here, all the irregular verb rules are created with buildIrregularVerbRules. An example rule can be seen in the documentation
* of the function buildIrregularVerbs. In essence, every irregular verb will have 6 separate rules, one for each subject,
* and will require (verb exampleIrregular) as well as (subject subjectExample). Once fired, the rule will assert the full
* conjugated verb, as opposed to just an ending. Current count: 42
*/
(defrule irregularRules "This rule only fires, creating all the irregular verb rules, when the user indicates their verb is irregular"
   (or (regular No) (regular Non))
=>
   (buildIrregularVerbRules aller vais vas va allons allez vont)
   (buildIrregularVerbRules faire fais fais fait faison faites font)
   (buildIrregularVerbRules avoir ai as a avons avez ont)
   (buildIrregularVerbRules être suis es est sommes êtes sont)
   (buildIrregularVerbRules pouvoir peux peux peut pouvons pouvez peuvent)
   (buildIrregularVerbRules mettre mets mets met mettons mettez mettent)
   (buildIrregularVerbRules dire dis dis dit disons dites disent)
   (buildIrregularVerbRules devoir dois dois doit devons devez doivent)
   (buildIrregularVerbRules prendre prends prends prend prenons prenez prennent)
   (buildIrregularVerbRules vouloir veux veux veut voulons voulez veulent)
   (buildIrregularVerbRules savoir sais sais sait savons savez savent)
   (buildIrregularVerbRules voir vois vois voit voyons voyez voient)
   (buildIrregularVerbRules rendre rends rends rend rendons rendez rendent)
   (buildIrregularVerbRules venir viens viens vient venons venez viennent)
   (buildIrregularVerbRules comprendre comprends comprends comprend comprenons comprenez comprennent)
   (buildIrregularVerbRules tenir tiens tiens tient tenons tenez tiennent)
   (buildIrregularVerbRules suivre suis suis suit suivons suivez suivent)
   (buildIrregularVerbRules connaître connais connais connaît connaissons connaissez connaissent)
   (buildIrregularVerbRules croire crois crois croit croyons croyez croient)
   (buildIrregularVerbRules entendre entends entends entend entendons entendez entendent)
   (buildIrregularVerbRules remettre remets remets remet remettons remettez remettent)
   (buildIrregularVerbRules permettre permets permets permet permettons permettez permettent)
   (buildIrregularVerbRules devenir deviens deviens devient devenons devenez deviennent)
   (buildIrregularVerbRules partir pars pars part partons partez partent)
   (buildIrregularVerbRules servir sers sers sert servons servez servent)
   (buildIrregularVerbRules revenir reviens reviens revient revenons revenez reviennent)
   (buildIrregularVerbRules recevoir recois recois recoit recevrons recevrez recoivent)
   (buildIrregularVerbRules repondre reponds reponds repond rependons rependez rependent)
   (buildIrregularVerbRules vivre vis vis vit vivons vivez vivent)
   (buildIrregularVerbRules perdre perds perds perd perdons perdez perdent)
   (buildIrregularVerbRules ouvrir ouvre ouvres ouvre ouvrons ouvrez ouvrent)
   (buildIrregularVerbRules lire lis lis lit lisons lisez lisent)
   (buildIrregularVerbRules essayer essaie essaies essaie essayons essayez essaient)
   (buildIrregularVerbRules sortir sors sors sort sortons sortez sortent)
   (buildIrregularVerbRules reprendre reprends reprends reprend reprenons reprenez reprennent)
   (buildIrregularVerbRules apparternir appartiens appartiens appartient appartenons appartenez appartiennent)
   (buildIrregularVerbRules apprendre apprends apprends apprend apprenons apprenez apprennent)
   (buildIrregularVerbRules obtenir obtiens obtiens obtient obtenons obtenez obtiennent)
   (buildIrregularVerbRules atteindre atteins atteins atteint atteignons attegniez attegnent)
   (buildIrregularVerbRules produire produis produis produit produisons produisez produisent)
   (buildIrregularVerbRules ecrire ecris ecris ecrit ecrivons ecrivez ecrivent)
   (buildIrregularVerbRules defendre defends defends defends defendons defendez defendent)
)
