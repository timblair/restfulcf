<!--- -->
<fusedoc fuse="restfulcf/sample/helloworld/rest/Dispatcher.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a concrete representation of a ReSTful Dispatcher for the 'Hello World' sample app
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.Dispatcher" output="no">

	<!--- set the location of our controllers --->
	<cfset variables.controller_path = "restfulcf.sample.helloworld.rest.controllers">
	<!--- automatically translated hyphens in property key names to underscores --->
	<cfset variables.argument_translation = TRUE>

	<cffunction name="init" access="public" returntype="restfulcf.sample.helloworld.rest.Dispatcher" output="no" hint="I initialise this instance of the dispatcher.">
		<!--- run the parent class constructor to initialise the component --->
		<cfset super.init(argumentcollection=arguments)>
		<!--- use an application scope cache --->
		<cfset setCache(createobject("component", "restfulcf.framework.core.cache.ApplicationCache").init())>
		<!--- we're using the app scope for persistence for the sample app --->
		<cfparam name="application.worlds" default="#arraynew(1)#">
		<!--- add the 'world' resource: automatically creates routes based on the
		      Worlds controller; uses the controller_path set above to find it --->
		<cfset addResource("world")>
		<cfreturn this>
	</cffunction>

</cfcomponent>
