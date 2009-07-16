<!--- -->
<fusedoc fuse="restfulcf/sample/helloworld/public/Application.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I define the application settings for RESTfulCF example applicatino
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="false">

	<cfset this.name = "restfulcf_example_app_helloworld">
	<cfset this.applicationtimeout = createtimespan(0,2,0,0)>

	<cffunction name="onApplicationStart" returntype="boolean" output="no">
		<!--- set up a couple of example worlds --->
		<cfset application.worlds = [
			{ id = 1, name = "Hello", created_at = "1978-09-22 12:34:56", updated_at = NOW() },
			{ id = 2, name = "Goodbye", created_at = NOW(), updated_at = NOW() }
		]>
		<cfreturn TRUE>
	</cffunction>

	<cffunction name="onRequestStart" returntype="boolean" output="false">
		<cfargument name="thePage" type="string" required="true">
		<cfif structkeyexists(url, "_reload") AND isboolean(url['_reload']) AND url['_reload']>
			<cfset onApplicationStart()>
		</cfif>
		<cfreturn TRUE>
	</cffunction>

</cfcomponent>
