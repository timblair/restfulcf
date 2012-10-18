<!--- -->
<fusedoc fuse="restfulcf/test//runner.cfm" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am the test scripts runner
	</responsibilities>
</fusedoc>
--->

<cfparam name="URL.output" default="extjs">
<cfparam name="URL.quiet" default="false">

<cfparam name="URL.tests" default="">
<cfset comp_path = "">
<cfif len(url.tests)><cfset comp_path = "." & url.tests></cfif>

<cfset dir = expandPath("tests/" & url.tests)>
<cfoutput><h1>#dir#</h1></cfoutput>

<cfset DTS = createObject("component","mxunit.runner.DirectoryTestSuite")>
<cfset excludes = "InvalidMarkupTest,FiveSecondTest">
<cfinvoke component="#DTS#"
  method="run"
  directory="#dir#"
  recurse="true"
  excludes="#excludes#"
  returnvariable="Results"
  componentPath="restfulcf.test.tests#comp_path#" />

<cfif NOT URL.quiet>
  <cfif NOT StructIsEmpty(DTS.getCatastrophicErrors())>
    <cfdump var="#DTS.getCatastrophicErrors()#" expand="false" label="#StructCount(DTS.getCatastrophicErrors())# Catastrophic Errors">
  </cfif>

  <cfsetting showdebugoutput="true">
  <cfoutput>#results.getResultsOutput(URL.output)#</cfoutput>
</cfif>
