<!--- -->
<fusedoc fuse="restfulcf/framework/core/Authenticator.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am the base component that any authenticator should extend
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<cfset variables.instance = { realm = "Access Denied" }>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.Authenticator" output="no" hint="Intialise this component">
		<cfargument name="realm" type="string" required="yes" hint="The authentication realm">
		<cfset variables.instance.realm = arguments.realm>
		<cfreturn this>
	</cffunction>

	<cffunction name="isAuthenticated" access="public" returntype="boolean" output="no" hint="The actual authentication method; should be overridden, else returns TRUE for everything.">
		<cfargument name="user" type="string" required="yes" hint="The username">
		<cfargument name="pass" type="string" required="yes" hint="The password">
		<cfreturn TRUE>
	</cffunction>

	<cffunction name="getRealm" access="public" returntype="string" output="no" hint="Returns the authentication realm">
		<cfreturn variables.instance.realm>
	</cffunction>

</cfcomponent>
