<!---  -->
<fusedoc fuse="restfulcf/framework/util/Inflector.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a CF version of portions of the Ruby on Rails Inflector class, specifically the
		functions which provide the ability to generate singulars/plurals of given words,
		plus some translation functions.
	</responsibilities>
</fusedoc>
--->

<cfcomponent displayname="Inflector" output="no">

	<!--- SETUP --->

	<cfset variables.plurals      = arraynew(1)>
	<cfset variables.singulars    = arraynew(1)>
	<cfset variables.irregulars   = arraynew(1)>
	<cfset variables.uncountables = "">

	<cfscript>
		// singular -> plural rules (most generic first)
		plural('$', 's');
		plural('s$', 's');
		plural('(ax|test)is$', '\1es');
		plural('(octop|vir)us$', '\1i');
		plural('(alias|status)$', '\1es');
		plural('(bu)s$', '\1ses');
		plural('(buffal|tomat)o$', '\1oes');
		plural('([ti])um$', '\1a');
		plural('sis$', 'ses');
		plural('(?:([^f])fe|([lr])f)$', '\1\2ves');
		plural('(hive)$', '\1s');
		plural('([^aeiouy]|qu)y$', '\1ies');
		plural('(x|ch|ss|sh)$', '\1es');
		plural('(matr|vert|ind)(?:ix|ex)$', '\1ices');
		plural('([m|l])ouse$', '\1ice');
		plural('^(ox)$', '\1en');
		plural('(quiz)$', '\1zes');
		// plural -> singular rules (most generic first)
		singular('s$', '');
		singular('(n)ews$', '\1ews');
		singular('([ti])a$', '\1um');
		singular('((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$', '\1\2sis');
		singular('(^analy)ses$', '\1sis');
		singular('([^f])ves$', '\1fe');
		singular('(hive)s$', '\1');
		singular('(tive)s$', '\1');
		singular('([lr])ves$', '\1f');
		singular('([^aeiouy]|qu)ies$', '\1y');
		singular('(s)eries$', '\1eries');
		singular('(m)ovies$', '\1ovie');
		singular('(x|ch|ss|sh)es$', '\1');
		singular('([m|l])ice$', '\1ouse');
		singular('(bus)es$', '\1');
		singular('(o)es$', '\1');
		singular('(shoe)s$', '\1');
		singular('(cris|ax|test)es$', '\1is');
		singular('(octop|vir)i$', '\1us');
		singular('(alias|status)es$', '\1');
		singular('^(ox)en', '\1');
		singular('(vert|ind)ices$', '\1ex');
		singular('(matr)ices$', '\1ix');
		singular('(quiz)zes$', '\1');
		singular('(database)s$', '\1');
		// irregulars (singular, plural)
		irregular('person', 'people');
		irregular('man', 'men');
		irregular('child', 'children');
		irregular('sex', 'sexes');
		irregular('move', 'moves');
		// uncountables (words that don't change)
		uncountable('equipment');
		uncountable('information');
		uncountable('rice');
		uncountable('money');
		uncountable('species');
		uncountable('series');
		uncountable('fish');
		uncountable('sheep');
	</cfscript>

	<!--- PUBLIC callable functions --->

	<!--- function for returning the plural form of a word --->
	<cffunction name="pluralise" access="public" returntype="string" output="no" hint="Returns the plural form of a word">
		<cfargument name="word" type="string" required="yes" hint="The word to get the plural for">
		<cfset var i = 0>
		<cfif NOT listfind(variables.uncountables, lcase(arguments.word))>
			<cfloop from="1" to="#arraylen(variables.plurals)#" index="i">
				<cfif refindnocase(variables.plurals[i]['rule'], arguments.word)>
					<cfset arguments.word = rereplacenocase(arguments.word, variables.plurals[i]['rule'], variables.plurals[i]['replacement'])>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn arguments.word>
	</cffunction>

	<!--- function for returning the singular form of a word --->
	<cffunction name="singularise" access="public" returntype="string" output="no" hint="Returns the singular form of a word">
		<cfargument name="word" type="string" required="yes" hint="The word to get the singular for">
		<cfset var i = 0>
		<cfif NOT listfind(variables.uncountables, lcase(arguments.word))>
			<cfloop from="1" to="#arraylen(variables.singulars)#" index="i">
				<cfif refindnocase(variables.singulars[i]['rule'], arguments.word)>
					<cfset arguments.word = rereplacenocase(arguments.word, variables.singulars[i]['rule'], variables.singulars[i]['replacement'])>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn arguments.word>
	</cffunction>


	<!--- function for capitalising the first character of a string --->
	<cffunction name="capitalise" access="public" returntype="string" output="no" hint="Capitalises the first character in a string">
		<cfargument name="string" type="string" required="yes" hint="The string to capitalise">
		<cfif len(arguments.string) LT 2><cfreturn ucase(arguments.string)></cfif>
		<cfreturn ucase(left(arguments.string, 1)) & right(arguments.string, len(arguments.string)-1)>
	</cffunction>

	<!--- function for CamelCasing a string --->
	<cffunction name="CamelCase" access="public" returntype="string" output="no" hint="Returns a given string, converted to CamelCase.  All non-alphanum characters are stripped.">
		<cfargument name="string" type="string" required="yes" hint="The string to CamelCase">
		<cfset var str = "">
		<cfset var i = 0>
		<!--- split the string into tokens based on non-alphanum characters --->
		<cfset var tokens = trim(arguments.string).split("[^a-zA-Z0-9]")>
		<cfloop from="1" to="#arraylen(tokens)#" index="i">
			<!--- loop through each token and capitalise it --->
			<cfif len(tokens[i])><cfset str = str & capitalise(tokens[i])></cfif>
		</cfloop>
		<cfreturn str>
	</cffunction>

	<!--- function for variablising a string --->
	<cffunction name="variablise" access="public" returntype="string" output="no" hint="Converts a string to a variable name, e.g. CamelCase becomes camel_case, 'big CSSDogThing' becomes big_css_dog_thing etc.">
		<cfargument name="string" type="string" required="yes" hint="The string to variablise">
		<cfset arguments.string = replace(trim(rereplace(arguments.string, "([^[:alnum:]_-]+)", " ", "ALL")), " ", "-", "ALL")>
		<cfset arguments.string = rereplace(arguments.string, "([A-Z]+)([A-Z][a-z])", "\1_\2", "ALL")>
		<cfset arguments.string = rereplace(arguments.string, "([a-z\d])([A-Z])", "\1_\2", "ALL")>
		<cfreturn lcase(replace(arguments.string, "-", "_", "ALL"))>
	</cffunction>

	<!--- function for humanising a string --->
	<cffunction name="humanise" access="public" returntype="string" output="no" hint="Converts a string to a human-readable string, e.g. CamelCase becomes Camel Case, my_field_id becomes my_field etc.">
		<cfargument name="string" type="string" required="yes" hint="The string to humanise">
		<cfset arguments.string = replace(trim(rereplace(rereplace(arguments.string, "_id$", ""), "([^[:alnum:]_-]+)", " ", "ALL")), "_", " ", "ALL")>
		<cfset arguments.string = rereplace(arguments.string, "([A-Z]+)([A-Z][a-z])", "\1 \2", "ALL")>
		<cfreturn rereplace(arguments.string, "([a-z\d])([A-Z])", "\1 \2", "ALL")>
	</cffunction>

	<!--- function for working out if a given character is upper-case --->
	<cffunction name="isCapital" access="public" returntype="boolean" output="no" hint="Is a given character upper-case?">
		<cfargument name="char" type="string" required="yes" hint="">
		<cfreturn asc(char) GTE 65 AND asc(char) LTE 90>
	</cffunction>

	<!--- function to pad a string with spaces --->
	<cffunction name="pad" access="public" returntype="string" output="no" hint="Pads a string with spaces up to a given length">
		<cfargument name="str" type="string" required="yes" hint="The string to pad">
		<cfargument name="minlen" type="numeric" required="yes" hint="The length to pad to">
		<cfif len(str) GTE arguments.minlen><cfreturn arguments.str></cfif>
		<cfreturn str & repeatstring(" ", arguments.minlen-len(arguments.str))>
	</cffunction>

	<!--- PRIVATE functions for component setup --->

	<!--- function for specifying a new pluralisation rule and its replacement --->
	<cffunction name="plural" access="private" returntype="void" output="no" hint="Specifies a new pluralisation rule and its replacement">
		<cfargument name="rule" type="string" required="yes" hint="The regex rule to match">
		<cfargument name="replacement" type="string" required="yes" hint="The replacement value to use for this rule">
		<cfset var pl = structnew()>
		<cfset pl.rule = arguments.rule>
		<cfset pl.replacement = arguments.replacement>
		<cfset arrayprepend(variables.plurals, pl)>
	</cffunction>

	<!--- function for specifying a new singularisation rule and its replacement --->
	<cffunction name="singular" access="private" returntype="void" output="no" hint="Specifies a new singularisation rule and its replacement">
		<cfargument name="rule" type="string" required="yes" hint="The regex rule to match">
		<cfargument name="replacement" type="string" required="yes" hint="The replacement value to use for this rule">
		<cfset var pl = structnew()>
		<cfset pl.rule = arguments.rule>
		<cfset pl.replacement = arguments.replacement>
		<cfset arrayprepend(variables.singulars, pl)>
	</cffunction>

	<!--- function for adding irregular words that don't fit any norms --->
	<cffunction name="irregular" access="private" returntype="void" output="no" hint="Adds irregular words to the inflector that don't conform to any norms">
		<cfargument name="sin" type="string" required="yes" hint="The singular form of the word">
		<cfargument name="plu" type="string" required="yes" hint="The plrual form of the word">
		<cfset plural('(#left(arguments.sin, 1)#)#right(arguments.sin, len(arguments.sin) - 1)#$', '\1' & right(arguments.plu, len(arguments.plu) - 1))>
		<cfset singular('(#left(arguments.plu, 1)#)#right(arguments.plu, len(arguments.plu) - 1)#$', '\1' & right(arguments.sin, len(arguments.sin) - 1))>
	</cffunction>

	<!--- function for adding uncountable words that shouldn't be inflected --->
	<cffunction name="uncountable" access="private" returntype="void" output="no" hint="Adds uncountable words that shouldn't be inflected">
		<cfargument name="word" type="string" required="yes" hint="The word to add to the uncountable list">
		<cfset variables.uncountables = listappend(variables.uncountables, arguments.word)>
	</cffunction>

</cfcomponent>
