<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/AuthenticatorTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the base authenticator
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset authenticator = createobject("component", "restfulcf.framework.core.Authenticator").init("test_realm")>
	</cffunction>

	<cffunction name="init_should_return_instance_of_authenticator">
		<cfset assertIsTypeOf(authenticator, "restfulcf.framework.core.Authenticator")>
	</cffunction>

	<cffunction name="is_authenticated_should_always_return_true">
		<cfset var i = 0>
		<cfloop from="1" to="10" index="i">
			<cfset assertTrue(authenticator.isAuthenticated(random_string(), random_string()))>
		</cfloop>
	</cffunction>

	<cffunction name="intialised_authentication_realm_should_be_correct">
		<cfset assertEquals("test_realm", authenticator.getRealm())>
	</cffunction>
	<cffunction name="default_authentication_realm_should_be_access_denied">
		<cfset assertEquals("Access Denied", createobject("component", "restfulcf.framework.core.Authenticator").getRealm())>
	</cffunction>

	<cffunction name="random_string" access="private" returntype="string" output="no" hint="Returns a randomly generated string">
		<cfset var chars = "0123456789abcdefghijklmnopqrstuvwxyzABCEDFGHIJKLMNOPQRSTUVWXYZ">
		<cfset var string = []>
		<cfset var i = 0>
		<cfset randomize(right(gettickcount(), 6) * rand())>
		<cfloop from="1" to="#ceiling(rand() * 10)#" index="i">
			<cfset arrayappend(string, mid(chars, ceiling(rand() * len(chars)), 1))>
		</cfloop>
		<cfreturn arraytolist(string, "")>
	</cffunction>

</cfcomponent>
