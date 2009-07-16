<!--- -->
<fusedoc fuse="restfulcf/framework/core/Request.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I represent an individual request for a resource
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<cfset variables.instance = {
		dispatcher = "",
		route      = createobject("component", "restfulcf.framework.core.Route"),
		uri        = "",
		type       = "",
		mime       = "",
		arguments  = {},
		fn_args    = {},
		arg_trans  = FALSE
	}>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.Request" output="no" hint="I initialise this instance">
		<cfargument name="dispatcher" type="restfulcf.framework.core.Dispatcher" required="yes" hint="A reference to the calling dispatcher">
		<cfargument name="route" type="restfulcf.framework.core.Route" required="yes" hint="The route that can handle this request">
		<cfargument name="uri" type="string" required="yes" hint="The resource URI (excluding requested response type)">
		<cfargument name="type" type="string" required="yes" hint="The requested response type">
		<cfargument name="mime" type="string" required="yes" hint="The mime type of the request (not the response)">
		<cfargument name="arg_trans" type="boolean" required="no" hint="Should we be converting dashes in argument names in to underscores?">
		<cfset var arg = "">
		<cfset var controller = "">
		<cfloop collection="#arguments#" item="arg">
			<cfif structkeyexists(variables.instance, arg)>
				<cfset variables.instance[arg] = arguments[arg]>
			</cfif>
		</cfloop>
		<cfset controller = variables.instance.dispatcher.getController(variables.instance.route.getController())>
		<cfloop array="#getmetadata(controller[variables.instance.route.getMethod()]).parameters#" index="arg">
			<cfparam name="arg.type" default="any">
			<cfset variables.instance.fn_args[arg.name] = arg.type>
		</cfloop>
		<cfset variables.instance.arguments = buildArgs()>
		<cfreturn this>
	</cffunction>

	<cffunction name="run" access="public" returntype="restfulcf.framework.core.Response" output="no" hint="Runs this request and responds with an encapsulated Response">
		<cfset var response = createobject("component", "restfulcf.framework.core.Response").init(this)>
		<cfset var controller = variables.instance.dispatcher.getController(variables.instance.route.getController())>
		<cfset var vo        = "">
		<cfset var resp      = "">
		<cfset var args      = duplicate(variables.instance.arguments)>

		<!--- add the request and response objects in whatever --->
		<cfset args['_request'] = this>
		<cfset args['_response'] = response>

		<!--- call the appropriate request method, then get the representation for the returned object --->
		<cftry>
			<cfinvoke component          = "#controller#"
			          method             = "#variables.instance.route.getMethod()#"
			          returnvariable     = "vo"
			          argumentcollection = "#args#">
			<!--- any missing arguments are treated as a bad request --->
			<cfcatch type="coldfusion.runtime.MissingArgumentException">
				<!--- anything that does originate from this file is a bigger problem --->
				<cfif cfcatch.tagcontext[1].template NEQ getcurrenttemplatepath()><cfrethrow></cfif>
				<cfset response.setStatusCode(controller.HTTP_STATUS_CODES['unprocessable_entity'])>
				<cfset response.addError("#cfcatch.paramname# is required")>
			</cfcatch>
			<cfcatch type="any">
				<cfif find("coldfusion.runtime.UDFMethod$InvalidArgumentTypeException", trim(cfcatch.stacktrace)) EQ 1>
					<cfif cfcatch.tagcontext[2].template NEQ getcurrenttemplatepath()><cfrethrow></cfif>
					<cfset response.setStatusCode(controller.HTTP_STATUS_CODES['unprocessable_entity'])>
					<cfset response.addError("#cfcatch.arg# is of the incorrect type (expected #cfcatch.type#)")>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>

		<!--- if there are any errors, use the error object as the response instead --->
		<cfif response.hasErrors()><cfset vo = response.getErrorCollection()></cfif>

		<!--- only set the response if we've got back an object that responds to the correct to* type --->
		<cfif isdefined("vo") AND isobject(vo)>
			<cfif structkeyexists(vo, "to#variables.instance.type#") AND iscustomfunction(vo["to#variables.instance.type#"])>
				<cfinvoke component="#vo#" method="to#variables.instance.type#" _response="#response#" returnvariable="resp">
				<cfif isdefined("resp") AND len(resp)><cfset response.setResponseBody(resp)></cfif>
			<cfelse>
				<cfset response.setStatusCode(controller.HTTP_STATUS_CODES['unsupported_media_type'])>
			</cfif>
		</cfif>

		<!--- return the response object --->
		<cfreturn response>
	</cffunction>

	<cffunction name="buildArgs" access="private" returntype="struct" output="no" hint="Collects the arguments for this request from various sources">
		<cfset var post_body = "">
		<cfset var xml       = {}>
		<cfset var key       = "">
		<cfset var cond      = "">
		<cfset var arg_keys  = "">
		<cfset var arg       = "">
		<!---
			build the arguments to send to the appropriate function, including refs to the request
			and response objects.  Argument precedence is:

			1. path vars (e.g. the ID from /resource/:id)
			2. decoded XML data from the body of a POST or PUT
			3. anything from the FORM scope
			4. anything from the URL scope, including decoded "structured" conditions

			The request and response objects always get thrown in as well (as _request and _response)
		--->
		<cfset var args = variables.instance.route.getPathVars(variables.instance.uri)>

		<!--- POST/PUT might be sending data as encoded XML in the POST body: assume that all data is top-level --->
		<!--- just check for the sub-type, as we might be using text/xml or application/xml --->
		<cfif listfind("POST,PUT", variables.instance.route.getVerb()) AND listlast(variables.instance.mime, "/") EQ "xml">
			<cfset post_body = gethttprequestdata().content>
			<cfif isbinary(post_body)><cfset post_body = tostring(tobinary(post_body))></cfif>
			<cfif isxml(trim(post_body))>
				<cfset xml = createobject("component", "restfulcf.framework.util.XML").toStruct(xml=post_body, include_root=FALSE)>
				<!--- remove any 'nil' attributes (thanks, rails...) --->
				<cfloop collection="#xml#" item="key">
					<cfif structkeyexists(xml, key & "::attributes")
					  AND structkeyexists(xml[key & "::attributes"], "nil")
					  AND isboolean(xml[key & "::attributes"]['nil'])
					  AND xml[key & "::attributes"]['nil']>
						<cfset arg_name = key>
						<cfif variables.instance.arg_trans><cfset arg_name = replace(key, "-", "_", "ALL")></cfif>
						<!--- is this nil arg an argument of the route function --->
						<cfif structkeyexists(variables.instance.fn_args, arg_name)>
							<!--- is it a string or something we'll treat as a string? --->
							<cfif listfind("string,any", variables.instance.fn_args[arg_name])>
								<cfset xml[key] = "">
							<!--- is it an _id field --->
							<cfelseif len(arg_name) GTE 4 AND right(arg_name, 3) EQ "_id">
								<cfset xml[key] = 0>
							<!--- neither of the above, so ignore it --->
							<cfelse><cfset structdelete(xml, key)></cfif>
						<!--- if it's nil and not an argument to this function, ignore it completely --->
						<cfelse><cfset structdelete(xml, key)></cfif>
					</cfif>
				</cfloop>
				<!--- we're only accepting single-level vars, so anything that's not a simple value should be removed --->
				<cfloop collection="#xml#" item="key">
					<cfif NOT issimplevalue(xml[key])><cfset structdelete(xml, key)></cfif>
				</cfloop>
				<cfset structappend(args, xml, FALSE)>
			</cfif>
		</cfif>

		<!--- add any form and url vars to the arguments --->
		<cfset structappend(args, form, FALSE)>
		<cfloop collection="#url#" item="key">
			<!--- we may have "structured" conditions in the URL scope, e.g. "conditions[name]=x&conditions[id]=1" --->
			<cfif lcase(listfirst(key, "[")) EQ "conditions" AND right(key, 1) EQ "]">
				<cfset cond = listlast(left(key, len(key)-1), "[")>
				<cfif NOT structkeyexists(args, cond)><cfset args[cond] = url[key]></cfif>
			<cfelseif NOT structkeyexists(args, key)><cfset args[key] = url[key]></cfif>
		</cfloop>

		<!--- do any parameter name translation --->
		<cfif variables.instance.arg_trans>
			<cfset arg_keys = structkeylist(args)>
			<cfloop list="#arg_keys#" index="arg">
				<cfif find("-", arg)>
					<cfset args[replace(arg, "-", "_", "ALL")] = args[arg]>
					<cfset structdelete(args, arg)>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn args>
	</cffunction>

	<!--- general getters to allow controllers to inspect where the request has come from --->
	<cffunction name="getDispatcher" access="public" returntype="restfulcf.framework.core.Dispatcher" output="no" hint="The calling dispatcher">
		<cfreturn variables.instance.dispatcher>
	</cffunction>
	<cffunction name="getRoute" access="public" returntype="restfulcf.framework.core.Route" output="no" hint="The route that matches the given URI">
		<cfreturn variables.instance.route>
	</cffunction>
	<cffunction name="getURI" access="public" returntype="string" output="no" hint="The requested URI">
		<cfreturn variables.instance.uri>
	</cffunction>
	<cffunction name="getResponseType" access="public" returntype="string" output="no" hint="The requested response type">
		<cfreturn variables.instance.type>
	</cffunction>
	<cffunction name="getArguments" access="public" returntype="struct" output="no" hint="The arguments for this request">
		<cfreturn variables.instance.arguments>
	</cffunction>

</cfcomponent>
