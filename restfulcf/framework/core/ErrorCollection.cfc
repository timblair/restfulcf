<!--- -->
<fusedoc fuse="restfulcf/framework/core/RouteCollection.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a collection of routes
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.Resource" output="no">

	<cfproperty name="errors" type="array">
	<cfset variables.instance = { errors = [] }>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.ErrorCollection" output="no" hint="I am a general initialiser for this resource">
		<cfargument name="errors" type="array" required="yes" hint="The array of simple error values">
		<cfset super.init(argumentcollection=arguments)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getErrors" access="public" returntype="array" output="no" hint="Returns the raw array of errors">
		<cfreturn duplicate(variables.instance.errors)>
	</cffunction>

	<cffunction name="getErrorCount" access="public" returntype="numeric" output="no" hint="Returns the number of errors in this collection">
		<cfreturn arraylen(variables.instance.errors)>
	</cffunction>

	<cffunction name="toXML" access="public" returntype="xml" output="no">
		<cfset var xml = "">
		<cfset var error = "">
		<cfloop array="#variables.instance.errors#" index="error">
			<cfset xml = xml & "<error>" & xmlformat(error) & "</error>">
		</cfloop>
		<cfreturn '<errors type="array">' & xml & '</errors>'>
	</cffunction>

	<cffunction name="toJSON" access="public" returntype="string" output="no">
		<cfreturn serializejson(variables.instance.errors)>
	</cffunction>

	<cffunction name="toHTML" access="public" returntype="string" output="no">
		<cfset var html = "">
		<cfset var error = "">
		<cfloop array="#variables.instance.errors#" index="error">
			<cfset html = html & "<li>" & htmleditformat(error) & "</li>">
		</cfloop>
		<cfreturn '<ul>' & html & '</ul>'>
	</cffunction>

	<cffunction name="toTxt" access="public" returntype="string" output="no">
		<cfreturn arraytolist(variables.instance.errors, chr(10))>
	</cffunction>

</cfcomponent>
