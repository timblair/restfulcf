<!--- -->
<fusedoc fuse="restfulcf/framework/core/Resource.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am the base class for resources
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<!--- what's the data type here: auto-built from component name if not provided --->
	<cfset variables.type = "">
	<!--- properties for this component: auto-filled on init() by any <cfproperty>s --->
	<cfset variables.properties = {}>
	<!--- all instance vars are stored here --->
	<cfset variables.instance = {}>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.Resource" output="no" hint="I am a general initialiser for this resource">
		<cfset var local = { meta = getmetadata(this) }>
		<!--- load properties --->
		<cfif structkeyexists(local.meta, "properties")>
			<cfloop array="#local.meta.properties#" index="local.prop">
				<!--- build up the local metadata for this property --->
				<cfset local.prop_data = {}>
				<cfloop collection="#local.prop#" item="local.prop_param">
					<cfif local.prop_param NEQ "name"><cfset local.prop_data[lcase(local.prop_param)] = local.prop[local.prop_param]></cfif>
				</cfloop>
				<!--- any id or _id field should default to an integer --->
				<cfif local.prop.name EQ "id" OR (len(local.prop.name) GTE 4 AND right(local.prop.name, 3) EQ "_id")>
					<cfparam name="local.prop_data.type" default="numeric">
					<cfif local.prop_data.type EQ "numeric"><cfparam name="local.prop_data.precision" default="integer"></cfif>
				</cfif>
				<!--- anything else should at least allow any type --->
				<cfparam name="local.prop_data.type" default="any">
				<!--- default precision of numeric and date properties (integer and datetime respectively) --->
				<cfif local.prop_data.type EQ "numeric" AND NOT structkeyexists(local.prop_data, "precision")><cfset local.prop_data.precision = "any"></cfif>
				<cfif local.prop_data.type EQ "date" AND NOT structkeyexists(local.prop_data, "precision")><cfset local.prop_data.precision = "datetime"></cfif>
				<!--- store the property and set the default value where appropriate --->
				<cfset variables.properties[local.prop.name] = local.prop_data>
				<cfif structkeyexists(local.prop, "default")>
					<cfinvoke component="#this#" method="set#local.prop.name#" value="#local.prop.default#">
				</cfif>
			</cfloop>
		</cfif>
		<!--- work out the type if necessary --->
		<cfif NOT len(variables.type)>
			<cfset local.inflector = createobject("component", "restfulcf.framework.util.Inflector")>
			<cfset variables.type = local.inflector.variablise(local.inflector.singularise(listlast(local.meta.name, ".")))>
		</cfif>
		<!--- initialise any provided instance vars --->
		<cfloop collection="#arguments#" item="local.arg">
			<cfif structkeyexists(variables.properties, local.arg)>
				<cfinvoke component="#this#" method="set#local.arg#" value="#arguments[local.arg]#">
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>

	<!--- to provide a representation of a given resource, create the appropriate to* function to return the data --->
	<cffunction name="toXML" access="public" returntype="xml" output="no">
		<cfset var xml = []>
		<cfset var type = "">
		<cfset var value = "">
		<cfset var key = "">
		<cfset var keys = structkeyarray(variables.instance)>
		<cfset arraysort(keys, 'textnocase', 'asc')>
		<cfloop array="#keys#" index="key">
			<cfset value = variables.instance[key]>
			<!--- handle nested resources --->
			<cfif NOT issimplevalue(value)>
				<cfif isstruct(value) AND structkeyexists(value, "toXML")>
					<cfset arrayappend(xml, value.toXML())>
				<cfelse>
					<cfset arrayappend(xml, "<#lcase(key)#>" & xmlformat(value.toString()) & "</#lcase(key)#>")>
				</cfif>
			<!--- blank empty non-numeric or zero'd ID fields --->
			<cfelseif (NOT isnumeric(value) AND NOT len(value)) OR ((key EQ "id" OR (len(key) GTE 4 AND right(key, 3) EQ "_id")) AND isnumeric(value) AND value EQ 0)>
				<cfset arrayappend(xml, "<#lcase(key)# nil=""true"" />")>
			<!--- anything else --->
			<cfelse>
				<cfset type = "">
				<cfswitch expression="#variables.properties[key].type#">
					<!--- numeric values may have a precision --->
					<cfcase value="numeric">
						<cfswitch expression="#variables.properties[key].precision#">
							<cfcase value="float"><cfset type = "float"></cfcase>
							<cfcase value="decimal"><cfset type = "decimal"></cfcase>
							<cfcase value="integer"><cfset type = "integer"></cfcase>
						</cfswitch>
					</cfcase>
					<!--- booleans should just be 0/1 --->
					<cfcase value="boolean"><cfset type = "boolean"></cfcase>
					<!--- dates should be ODBC dates, times or datetimes --->
					<cfcase value="date">
						<cfswitch expression="#variables.properties[key].precision#">
							<cfcase value="date"><cfset type = "date"></cfcase>
							<cfcase value="time"><cfset type = "time"></cfcase>
							<cfdefaultcase><cfset type = "datetime"></cfdefaultcase>
						</cfswitch>
					</cfcase>
				</cfswitch>
				<!--- build the item XML string, including type if necessary --->
				<cfif len(type)><cfset type = ' type="#type#"'></cfif>
				<cfset arrayappend(xml, "<#lcase(key)##type#>" & xmlformat(value) & "</#lcase(key)#>")>
			</cfif>
		</cfloop>
		<cfreturn "<#variables.type#>" & arraytolist(xml, chr(10)) & "</#variables.type#>">
	</cffunction>

	<cffunction name="toHTML" access="public" returntype="string" output="no">
		<cfset var html = []>
		<cfset var val = "">
		<cfset var key = "">
		<cfset var keys = structkeyarray(variables.instance)>
		<cfset arraysort(keys, 'textnocase', 'asc')>
		<cfloop array="#keys#" index="key">
			<cfset val = variables.instance[key]>
			<!--- handle nested resources --->
			<cfif NOT issimplevalue(val)>
				<cfif isstruct(val) AND structkeyexists(val, "toHTML")>
					<cfset arrayappend(html, "<dt>#htmleditformat(lcase(key))#</dt><dd>" & val.toHTML() & "</dd>")>
				<cfelse>
					<cfset arrayappend(html, "<dt>#htmleditformat(lcase(key))#</dt><dd>" & val.toString() & "</dd>")>
				</cfif>
			<cfelse>
				<cfset arrayappend(html, "<dt>#htmleditformat(lcase(key))#</dt><dd>" & htmleditformat(val) & "</dd>")>
			</cfif>
		</cfloop>
		<cfreturn "<dl class=""#variables.type#"">" & arraytolist(html, chr(10)) & "</dl>">
	</cffunction>

	<cffunction name="toTXT" access="public" returntype="string" output="no">
		<cfreturn serializejson(variables.instance)>
	</cffunction>
	<cffunction name="toJSON" access="public" returntype="string" output="no">
		<cfreturn serializejson(variables.instance)>
	</cffunction>

	<!--- generic getter and setter functions --->
	<cffunction name="get" access="private" returntype="any" output="no" hint="I am a generic getter method, used internally and for auto-generated onMissingMethod() calls">
		<cfargument name="key" type="string" required="yes" hint="The key to retrieve">
		<cfif structkeyexists(variables.instance, arguments.key)>
			<cfreturn variables.instance[arguments.key]>
		<cfelse>
			<cfthrow type="Application" message="The method get#arguments.key# was not found in component #getMetaData(this).path#" detail="Ensure that the method is defined, and that it is spelled correctly.">
		</cfif>
	</cffunction>
	<cffunction name="set" access="private" returntype="void" output="no" hint="I am a generic setter method, used internally and for auto-generated onMissingMethod() calls">
		<cfargument name="key" type="string" required="yes" hint="The key to set">
		<cfargument name="value" type="any" required="yes" hint="The value to set">
		<cfif structkeyexists(variables.properties, arguments.key)>
			<cfif isvalid(variables.properties[arguments.key].type, arguments.value)>
				<!--- massage input values into the correct form depending on property type and precision --->
				<cfswitch expression="#variables.properties[arguments.key].type#">
					<cfcase value="date">
						<cfswitch expression="#variables.properties[arguments.key].precision#">
							<cfcase value="date"><cfset arguments.value = createodbcdate(arguments.value)></cfcase>
							<cfcase value="time"><cfset arguments.value = createodbctime(arguments.value)></cfcase>
							<cfdefaultcase><cfset arguments.value = createodbcdatetime(arguments.value)></cfdefaultcase>
						</cfswitch>
					</cfcase>
					<cfcase value="numeric">
						<cfswitch expression="#variables.properties[arguments.key].precision#">
							<cfcase value="float"><cfset arguments.value = val(trim(numberformat(arguments.value, "99999999999999.09999999999999")))></cfcase>
							<cfcase value="decimal"><cfset arguments.value = val(trim(numberformat(arguments.value, "99999999999999.00")))></cfcase>
							<cfcase value="integer"><cfset arguments.value = int(arguments.value)></cfcase>
						</cfswitch>
					</cfcase>
					<cfcase value="boolean">
						<cfif arguments.value><cfset arguments.value = 1><cfelse><cfset arguments.value = 0></cfif>
					</cfcase>
				</cfswitch>
				<cfset variables.instance[arguments.key] = arguments.value>
			<cfelse>
				<cfthrow type="Application" message="The value to set#arguments.key# must be of type #variables.properties[arguments.key].type#." detail="The value provided was <code>#arguments.value#</code>.">
			</cfif>
		<cfelse>
			<cfthrow type="Application" message="The method set#arguments.key# was not found in component #getMetaData(this).path#" detail="Ensure that the method is defined, and that it is spelled correctly.">
		</cfif>
	</cffunction>

	<!--- handle any set/get calls or cases of missing on* methods nicely --->
	<cffunction name="onMissingMethod" access="public" returntype="any" output="no">
		<cfargument name="missingMethodName" type="string" required="yes" hint="The method name called">
		<cfargument name="missingMethodArguments" type="struct" required="yes" hint="Any arguments the method was called with">
		<cfset var method = lcase(missingMethodName)>
		<cfif find("get", method) EQ 1>
			<cfreturn get(right(method, len(method)-3), arguments.missingMethodArguments[1])>
		<cfelseif find("set", method) EQ 1>
			<cfset set(right(method, len(method)-3), arguments.missingMethodArguments[1])>
		<cfelse>
			<cfthrow type="Application" message="The method #arguments.missingMethodName# was not found in component #getMetaData(this).path#" detail="Ensure that the method is defined, and that it is spelled correctly.">
		</cfif>
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="struct" output="no" hint="Returns a copy of the properties listed for this object">
		<cfreturn structcopy(variables.properties)>
	</cffunction>

</cfcomponent>
