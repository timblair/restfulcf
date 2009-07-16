<!--- -->
<fusedoc fuse="restfulcf/framework/core/Response.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a response object that gets passed to and updated by controller methods
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<cfset variables.instance = {
		status_code   = 200,
		status_text   = "",
		response_type = "application/xml",
		response_body = "",
		response_file = "",
		response_uri  = "",
		errors        = [],
		request       = createobject("component", "restfulcf.framework.core.Request")
	}>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.Response" output="no" hint="I am the encapsulation of a request response">
		<cfargument name="request" type="restfulcf.framework.core.Request" required="no" hint="The request object that resulted in this response">
		<cfif structkeyexists(arguments, "request")><cfset variables.instance.request = arguments.request></cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="getStatusCode" access="public" returntype="numeric" output="no" hint="Get the response status code for this request">
		<cfreturn variables.instance.status_code>
	</cffunction>
	<cffunction name="setStatusCode" access="public" returntype="void" output="no" hint="Set the response status code for this request">
		<cfargument name="code" type="numeric" required="yes" hint="The response status code for this request">
		<cfset variables.instance.status_code = arguments.code>
	</cffunction>

	<cffunction name="getStatusText" access="public" returntype="string" output="no" hint="Get the response status text for this request">
		<cfreturn variables.instance.status_text>
	</cffunction>
	<cffunction name="setStatusText" access="public" returntype="void" output="no" hint="Set the response status text for this request.">
		<cfargument name="text" type="string" required="yes" hint="The response status message for this request">
		<cfset variables.instance.status_text = arguments.text>
	</cffunction>

	<cffunction name="getResponseType" access="public" returntype="string" output="no" hint="Get the response type for this request">
		<cfreturn variables.instance.response_type>
	</cffunction>
	<cffunction name="setResponseType" access="public" returntype="void" output="no" hint="Set the response type for this request">
		<cfargument name="type" type="string" required="yes" hint="The response type for this request">
		<cfset variables.instance.response_type = arguments.type>
	</cffunction>

	<cffunction name="getResponseURI" access="public" returntype="string" output="no" hint="Get the response URI for this request">
		<cfreturn variables.instance.response_uri>
	</cffunction>
	<cffunction name="setResponseURI" access="public" returntype="void" output="no" hint="Set the response URI for this request (will be set as the Location: header)">
		<cfargument name="uri" type="string" required="yes" hint="The response URI for this request">
		<cfset variables.instance.response_uri = arguments.uri>
	</cffunction>

	<cffunction name="getResponseBody" access="public" returntype="any" output="no" hint="Get the response data for this request">
		<cfreturn variables.instance.response_body>
	</cffunction>
	<cffunction name="setResponseBody" access="public" returntype="void" output="no" hint="Set the response data for this request">
		<cfargument name="data" type="any" required="yes" hint="The response data for this request">
		<cfset variables.instance.response_body = arguments.data>
	</cffunction>

	<cffunction name="getResponseFile" access="public" returntype="any" output="no" hint="Get the response file for this request">
		<cfreturn variables.instance.response_file>
	</cffunction>
	<cffunction name="setResponseFile" access="public" returntype="void" output="no" hint="Set the response file for this request (send this file instead of the body content if provided)">
		<cfargument name="filepath" type="any" required="yes" hint="The full file path for the file">
		<cfset variables.instance.response_file = arguments.filepath>
	</cffunction>

	<cffunction name="addError" access="public" returntype="void" output="no" hint="Adds an error to the error list">
		<cfargument name="error" type="string" required="yes" hint="The error text">
		<cfset arrayappend(variables.instance.errors, arguments.error)>
	</cffunction>
	<cffunction name="hasErrors" access="public" returntype="boolean" output="no" hint="Are there any errors associated with this response">
		<cfreturn NOT NOT arraylen(variables.instance.errors)>
	</cffunction>
	<cffunction name="getErrorCollection" access="public" returntype="restfulcf.framework.core.ErrorCollection" output="no" hint="Returns the error list">
		<cfreturn createobject("component", "restfulcf.framework.core.ErrorCollection").init(variables.instance.errors)>
	</cffunction>

	<cffunction name="getRequest" access="public" returntype="restfulcf.framework.core.Request" output="no" hint="Returns the request object that resulted in this response">
		<cfreturn variables.instance.request>
	</cffunction>

</cfcomponent>
