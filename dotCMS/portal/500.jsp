<%@ page import="java.util.*" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.lang.Exception" %>
<%@ page import="com.dotmarketing.util.UtilMethods" %>
<%@ page import="com.dotmarketing.beans.Host" %>
<%@ page import="com.dotmarketing.business.web.WebAPILocator"%>
<%@ page import="com.dotmarketing.business.CacheLocator"%>
<%@ page import="com.dotmarketing.util.Logger"%>
<%@ page import="com.dotmarketing.db.DbConnectionFactory"%>
<%@ page import="org.apache.commons.lang.StringEscapeUtils"%>
<%try{		
	Host host = WebAPILocator.getHostWebAPI().getCurrentHost(request);
		
	String ep_originatingHost = host.getHostname();
	String ep_errorCode = "500";
	
	// Get 500 from virtual link
	String pointer = (String) com.dotmarketing.cache.VirtualLinksCache.getPathFromCache(host.getHostname() + ":/cms500Page");
	if (!UtilMethods.isSet(pointer)) {
		pointer = (String) com.dotmarketing.cache.VirtualLinksCache.getPathFromCache("/cms500Page");
	}
	
	Logger.debug(this, "cms500Page path is: " + pointer);
	
	// if we have a virtual link, see if the page exists.  pointer will be set to null if not
	if (UtilMethods.isSet(pointer)) {
		if (pointer.startsWith("/")) {
		// if the virtual link is a relative path, the path is validated within the current host
			pointer = com.dotmarketing.cache.LiveCache.getPathFromCache(pointer, host);	
			Logger.debug(this, "cms500Page relative path is: " + pointer + " - host: " + host.getHostname() + " and pointer: " + pointer);
		} else {
		// if virtual link points to a host or alias in dotCMS server, the path needs to be validated.
		// Otherwise, the original external pointer is kept for the redirect

			try {
				URL errorPageUrl = new URL(pointer);
				String errorPageHost = errorPageUrl.getHost();
				String errorPagePath = errorPageUrl.getPath();
				
				Logger.debug(this, "cms500Page - errorPageHost: " + errorPageHost + " and errorPagePath: " + errorPagePath);
				
				Host internalHost = WebAPILocator.getHostWebAPI().findByName(errorPageHost, WebAPILocator.getUserWebAPI().getAnonymousUser(), true);
				Host internalAlias = WebAPILocator.getHostWebAPI().findByAlias(errorPageHost, WebAPILocator.getUserWebAPI().getAnonymousUser(), true);
				
				// 500 Virtual Link is pointing to a host in dotCMS
				if ( internalHost != null) {				
					String absPointer = com.dotmarketing.cache.LiveCache.getPathFromCache(errorPagePath, internalHost);
					if (absPointer == null) {
						pointer = null;
					}
					Logger.debug(this, "cms500Page absolute internal path is: " + pointer + " - internalHost: " + internalHost.getHostname() + " and errorPagePath: " + errorPagePath);
				
				// 500 Virtual Link is poiting to an alias in dotCMS
				} else if ( internalAlias != null) {
					String absPointer = com.dotmarketing.cache.LiveCache.getPathFromCache(errorPagePath, internalAlias);
					if (absPointer == null) {
						pointer = null;
					}
					Logger.debug(this, "cms500Page absolute internal path is: " + pointer + " - internalAlias: " + internalAlias.getHostname() + " and errorPagePath: " + errorPagePath);
				
				// 500 Virtual Link is pointing to an external page
				} else {
					Logger.debug(this, "cms500Page absolute external path is: " + pointer);
				}
					
			} catch (Exception e){
				Logger.error(this, "cms500Page path is incorrect: " + pointer + e.getMessage(), e);
				pointer = null;
			}
		}
	}
	
	// if we have virtual link and page exists, redirect or forward
	if(UtilMethods.isSet(pointer) ){
		if (pointer.startsWith("/")) {
			Logger.debug(this, "cms500Page forwarding to relative path: " + pointer);			
			request.getRequestDispatcher(pointer).forward(request, response);
		} else {
			pointer = pointer + "?ep_originatingHost="+ep_originatingHost+"&ep_errorCode="+ep_errorCode;
			Logger.debug(this, "cms500Page redirecting to absolute path: " + pointer);
			response.sendRedirect(pointer);
		}
		return;
	}
	
	
	%>
	
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
    <head>

    <script>
        function showError(){
            var ele = document.getElementById("error");
            if(ele.style.display=="none"){
                ele.style.display="";
            }
            else{
                ele.style.display="none";
            }
        
        }
        
        
    </script>
    
        <title>dotCMS: 500 error</title>

	<style type="text/css">
		body{
			font-family: verdana, helvetica, san-serif;
			padding:20px;
		}
		#main {
			width: 400px;
			font-family: verdana, helvetica, san-serif;
			font-size: 12px;
			margin-left:auto;
			margin-right:auto;
		}
		#footer {
			text-align:center;
			font-family: verdana, helvetica, san-serif;
			font-size: 12px;
		}
        h1 {
	        font-family: verdana, helvetica, san-serif;
	        font-size: 20px;
	        text-decoration: none;
	        font-weight: normal;
        }
        h2{
	        font-family: verdana, helvetica, san-serif;
	        font-size: 18px;
	        text-decoration: none;
	        font-weight: normal;
        }
		#logo{
			float: left;
		}
		#text{
			float: left;
		}
	</style>

    </head>
    <body>
        <div id="main">
			<div id="logo">
		<a href="http://dotcms.com"><img src="/html/images/skin/logo.gif" width="140"  hspace="10" border="0" alt="dotCMS content management system" title="dotCMS content management system"  /></a>
			</div>
            <div id="text">
	
                <h1>Server Error (500 error)</h1>
		
                <p>The page or file you were looking for caused a little tiny <a href="javascript:showError()">error</a>. 
                <BR/>Please make sure that you have typed the correct URL. </p>
                <p>If the problem persists, you can always return to the <a href="/">home page</a>.</p>
                
            </div>
        </div>
        <br clear="all"/>&nbsp;<br clear="all"/>
<div id="footer">&copy; <script>var d = new Date();document.write(d.getFullYear());</script>, <a href="http://dotcms.com">DM Web, Corp.</a></div>
        <br clear="all"/>&nbsp;<br clear="all"/>
		<div id="error" style="display: none;border: 1px #cccccc solid; padding:10px; margin:10px;width:80%">
		        <% Exception x = (Exception) request.getAttribute("javax.servlet.error.exception");%>
		        <%if(x instanceof javax.servlet.ServletException) {%>
			        <% javax.servlet.ServletException sx = (javax.servlet.ServletException) request.getAttribute("javax.servlet.error.exception");%>
			        <% if(sx != null){%>
			            <%java.lang.Throwable t = sx.getRootCause();%>
			            <%if(t != null){%>
			            <% t.printStackTrace();%>
			            <H2>Error information</H2>
			            <pre><%=t.toString()%><%  java.lang.StackTraceElement[] ste =t.getStackTrace();%><%for(int i = 0; i< ste.length;i++){%>
							<%=ste[i].toString()%><%}%>
			             </pre>
			             <%}%>
			        <%}%>
				<%}else{ %>
			        <% if(x != null){%>
			            <%java.lang.Throwable t = x.getCause();%>
			            <%if(t != null){%>
			            <% t.printStackTrace();%>
			            <H2>Error information</H2>
			            <pre><%=t.toString()%><%  java.lang.StackTraceElement[] ste =t.getStackTrace();%><%for(int i = 0; i< ste.length;i++){%>
							<%=ste[i].toString()%><%}%>
			             </pre>
			             <%}%>
			        <%}%>
				<%} %>
		
		</div>
		
    </body>
</html>
<%} catch( Exception e){
	Logger.error(this, "cms500Page cant display " + e.getMessage());	%>
500	
	
	
<% }finally{
	DbConnectionFactory.closeConnection();
}%>

