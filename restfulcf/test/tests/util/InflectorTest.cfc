<!--- -->
<fusedoc fuse="restfulcf/test/tests/util/InflectorTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the inflector to make sure it inflects things correctly
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<!--- case-sensitive asserts are currently only available in SVN for MXUnit (not standard release) --->
	<cfif NOT (structkeyexists(variables, "assertEqualsCase") AND iscustomfunction(variables.assertEqualsCase))>
		<cfset variables.assertEqualsCase = variables.assertEquals>
	</cfif>

	<cffunction name="setup">
		<cfset inflector = createObject("component", "restfulcf.framework.util.Inflector")>
	</cffunction>

	<!--- Capitalising --->
	<cffunction name="capitalise_should_capitalise_first_letter">
		<cfset assertEqualsCase("The big dog", inflector.capitalise("the big dog"))>
	</cffunction>
	<cffunction name="capitalise_should_not_change_already_capitalised_first_letter">
		<cfset assertEqualsCase("The big dog", inflector.capitalise("The big dog"))>
	</cffunction>
	<cffunction name="capitalise_should_capitalise_single_character">
		<cfset assertEqualsCase("X", inflector.capitalise("x"))>
	</cffunction>
	<cffunction name="is_capital_should_be_true_for_all_capital_letters">
		<cfset var i = 0>
		<cfloop from="65" to="90" index="i">
			<cfset assertTrue(inflector.isCapital(chr(i)))>
		</cfloop>
	</cffunction>
	<cffunction name="is_capital_should_be_false_for_all_non_capital_letters">
		<cfset var i = 0>
		<cfloop from="141" to="172" index="i">
			<cfset assertFalse(inflector.isCapital(chr(i)))>
		</cfloop>
	</cffunction>
	<cffunction name="is_capital_should_be_false_for_all_non_alpha_characters">
		<cfset var i = "">
		<cfloop list="1,2,6,7,8,@,£,$,^,),(,*,{,},_,<,>,?,*,[,],@,?" index="i">
			<cfset assertFalse(inflector.isCapital(i))>
		</cfloop>
	</cffunction>

	<!--- CamelCasing --->
	<cffunction name="camel_case_should_camel_case_spaced_string">
		<cfset assertEqualsCase("TheBigDog", inflector.CamelCase("the big dog"))>
	</cffunction>
	<cffunction name="camel_case_should_camel_case_underscored_string">
		<cfset assertEqualsCase("TheBigDog", inflector.CamelCase("the_big_dog"))>
	</cffunction>
	<cffunction name="camel_case_should_camel_case_string_with_non_alpha_chars">
		<cfset assertEqualsCase("TheBigDog", inflector.CamelCase("the{}{big^!*dog"))>
	</cffunction>
	<cffunction name="camel_case_should_not_change_an_already_camel_cased_string">
		<cfset assertEqualsCase("TheBigDog", inflector.CamelCase("TheBigDog"))>
	</cffunction>

	<!--- variablising --->
	<cffunction name="variablise_should_variablise_camel_cased_string">
		<cfset assertEqualsCase("the_big_dog", inflector.variablise("TheBigDog"))>
	</cffunction>
	<cffunction name="variablise_should_variablise_spaced_string">
		<cfset assertEqualsCase("the_big_dog", inflector.variablise("The big dog"))>
	</cffunction>
	<cffunction name="variablise_should_variablise_string_with_numbers">
		<cfset assertEqualsCase("area51_controller", inflector.variablise("area51Controller"))>
	</cffunction>
	<cffunction name="variablise_should_not_change_an_already_variablised_string">
		<cfset assertEqualsCase("the_big_dog", inflector.variablise("the_big_dog"))>
	</cffunction>
	<cffunction name="variablise_should_variablise_string_with_non_alpha_chars">
		<cfset assertEqualsCase("the_big_dog", inflector.variablise("^%*%^ The^%*%^ BigDog %^%*"))>
	</cffunction>
	<cffunction name="variablise_should_variablise_string_with_multiple_upcased_chars">
		<cfset assertEqualsCase("the_css_and_html_people", inflector.variablise("TheCSSAndHTMLPeople"))>
	</cffunction>

	<!--- humanising --->
	<cffunction name="humanise_should_humanise_camel_cased_string">
		<cfset assertEqualsCase("The Big Dog", inflector.humanise("TheBigDog"))>
	</cffunction>
	<cffunction name="humanise_should_humanise_variablise_string">
		<cfset assertEqualsCase("the big dog", inflector.humanise("the_big_dog"))>
	</cffunction>
	<cffunction name="humanise_should_not_change_already_humanised_string">
		<cfset assertEqualsCase("the big dog", inflector.humanise("the big dog"))>
	</cffunction>
	<cffunction name="humanise_should_humanise_string_with_non_alpha_chars">
		<cfset assertEqualsCase("The Big Dog", inflector.humanise("^%*%^ The^%*%^ BigDog %^%*"))>
	</cffunction>
	<cffunction name="humanise_should_humanise_string_with_multiple_upcased_chars">
		<cfset assertEqualsCase("The CSS And HTML People", inflector.humanise("TheCSSAndHTMLPeople"))>
	</cffunction>
	<cffunction name="humanise_string_ending_with_id_should_remove_id">
		<cfset assertEqualsCase("another test", inflector.humanise("another_test_id"))>
	</cffunction>

	<!--- string padding --->
	<cffunction name="pad_should_pad_string_to_max_length">
		<cfset assertEquals(20, len(inflector.pad(repeatstring("x", 10), 20)))>
	</cffunction>
	<cffunction name="pad_should_return_string_if_length_greater_than_max_pad_length">
		<cfset assertEquals(30, len(inflector.pad(repeatstring("x", 30), 20)))>
	</cffunction>

	<!--- pluralisation and singularisation --->
	<cfset singular_to_plural = {
		search       = "searches",
		switch       = "switches",
		fix          = "fixes",
		box          = "boxes",
		process      = "processes",
		address      = "addresses",
		case         = "cases",
		stack        = "stacks",
		wish         = "wishes",
		fish         = "fish",
		jeans        = "jeans",
		category     = "categories",
		query        = "queries",
		ability      = "abilities",
		agency       = "agencies",
		movie        = "movies",
		archive      = "archives",
		index        = "indices",
		wife         = "wives",
		safe         = "saves",
		half         = "halves",
		move         = "moves",
		salesperson  = "salespeople",
		person       = "people",
		spokesman    = "spokesmen",
		man          = "men",
		woman        = "women",
		basis        = "bases",
		diagnosis    = "diagnoses",
		diagnosis_a  = "diagnosis_as",
		datum        = "data",
		medium       = "media",
		analysis     = "analyses",
		node_child   = "node_children",
		child        = "children",
		experience   = "experiences",
		day          = "days",
		comment      = "comments",
		foobar       = "foobars",
		newsletter   = "newsletters",
		old_news     = "old_news",
		news         = "news",
		series       = "series",
		species      = "species",
		quiz         = "quizzes",
		perspective  = "perspectives",
		ox           = "oxen",
		photo        = "photos",
		buffalo      = "buffaloes",
		tomato       = "tomatoes",
		dwarf        = "dwarves",
		elf          = "elves",
		information  = "information",
		equipment    = "equipment",
		bus          = "buses",
		status       = "statuses",
		status_code  = "status_codes",
		mouse        = "mice",
		louse        = "lice",
		house        = "houses",
		octopus      = "octopi",
		virus        = "viri",
		alias        = "aliases",
		portfolio    = "portfolios",
		vertex       = "vertices",
		matrix       = "matrices",
		matrix_fu    = "matrix_fus",
		axis         = "axes",
		testis       = "testes",
		crisis       = "crises",
		rice         = "rice",
		shoe         = "shoes",
		horse        = "horses",
		prize        = "prizes",
		edge         = "edges",
		database     = "databases",
		stadium      = "stadia",
		zombie       = "zombies"
	}>
	<cffunction name="pluralise_should_pluralise_simple_and_complex_words">
		<cfset var word = "">
		<cfloop collection="#singular_to_plural#" item="word">
			<cfset assertEquals(singular_to_plural[word], inflector.pluralise(word))>
		</cfloop>
	</cffunction>
	<cffunction name="singularise_should_singularise_simple_and_complex_words">
		<cfset var word = "">
		<cfloop collection="#singular_to_plural#" item="word">
			<cfset assertEquals(word, inflector.singularise(singular_to_plural[word]))>
		</cfloop>
	</cffunction>
	<cffunction name="pluralise_should_not_repluralise_already_plural_words">
		<cfset var word = "">
		<cfloop collection="#singular_to_plural#" item="word">
			<cfset assertEquals(singular_to_plural[word], inflector.pluralise(singular_to_plural[word]))>
		</cfloop>
	</cffunction>
	<cffunction name="singularise_should_not_resingularise_already_singular_words">
		<cfset var word = "">
		<cfloop collection="#singular_to_plural#" item="word">
			<cfset assertEquals(word, inflector.singularise(word))>
		</cfloop>
	</cffunction>

</cfcomponent>
