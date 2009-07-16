<!--- -->
<fusedoc fuse="restfulcf/framework/core/ResourceCount.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a resource that represents a simple count
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.Resource" output="no">

	<cfset variables.instance.type = "resource">
	<cfset variables.instance.count = 0>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.ResourceCount" output="no" hint="I initialise the component">
		<cfargument name="type" type="string" required="yes" hint="The type of resource that the collection holds">
		<cfargument name="count" type="numeric" required="no" hint="An optional initial count with which to populate this resource">
		<cfset var inflector = createobject("component", "restfulcf.framework.util.Inflector")>
		<cfset variables.instance.type = inflector.variablise(inflector.pluralise(arguments.type))>
		<cfif structkeyexists(arguments, "count")><cfset variables.instance.count = arguments.count></cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setCount" access="public" returntype="void" output="no" hint="Sets the count for this resource">
		<cfargument name="count" type="numeric" required="yes" hint="The count">
		<cfset variables.instance.count = arguments.count>
	</cffunction>
	<cffunction name="incCount" access="public" returntype="void" output="no" hint="Increases the count">
		<cfargument name="by" type="numeric" required="no" default="1" hint="The amount to increment the count by">
		<cfset variables.instance.count = variables.instance.count + arguments.by>
	</cffunction>
	<cffunction name="decCount" access="public" returntype="void" output="no" hint="Decreases the count">
		<cfargument name="by" type="numeric" required="no" default="1" hint="The amount to decrease the count by">
		<cfset variables.instance.count = variables.instance.count - arguments.by>
	</cffunction>

	<cffunction name="toXML" access="public" returntype="xml" output="no" hint="Returns this resource in XML format">
		<cfreturn "<#variables.instance.type#><count type=""integer"">#variables.instance.count#</count></#variables.instance.type#>">
	</cffunction>
	<cffunction name="toHTML" access="public" returntype="string" output="no" hint="Returns this resource in HTML format">
		<cfreturn "Number of " & createobject("component", "restfulcf.framework.util.Inflector").humanise(variables.instance.type) & " = " & variables.instance.count>
	</cffunction>

</cfcomponent>
