<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/ControllerTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the base controller
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset controller = createobject("component", "restfulcf.framework.core.Controller").init()>
	</cffunction>

	<cffunction name="init_should_return_instance_of_controller">
		<cfset assertIsTypeOf(controller, "restfulcf.framework.core.Controller")>
	</cffunction>

	<cffunction name="shortcut_http_status_codes_should_be_available_and_correct">
		<cfset var msg = "">
		<cfloop list="ok|200,created|201,not_found|404,method_not_allowed|405,not_acceptable|406,unsupported_media_type|415,unprocessable_entity|422,internal_server_error|500" index="msg">
			<cfset assertEquals(listgetat(msg, 2, "|"), controller.HTTP_STATUS_CODES[listgetat(msg, 1, "|")])>
		</cfloop>
	</cffunction>

</cfcomponent>
