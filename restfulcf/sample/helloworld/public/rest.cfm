<!--- -->
<fusedoc fuse="restfulcf/sample/helloworld/public/rest.cfm" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am the entry point for all REST calls
	</responsibilities>
</fusedoc>
--->

<!--- import the endpoint custom tag --->
<cfimport taglib="../../../framework/tags/" prefix="restfulcf">

<!--- run the request --->
<restfulcf:endpoint
	name     = application.applicationname,
	engine   = "restfulcf.sample.helloworld.rest.Dispatcher"
	reload   = TRUE
	response = "variables.response">
