<%@ page import="authdb.*,java.io.*,java.util.*" %>
<%

// Make sure this page will not be cached by the browser
response.addHeader("Pragma", "no-cache");
response.addHeader("Cache-Control", "no-store");

// We will send error messages to System.err, for verbosity. In a real
// application you will probably not want this. We will send a few log
// messages to System.out.
PrintStream errorStream = System.err;

// If we find any fatal error, we will store it in the "error" variable. If we
// need to store the exception too, we will store it in "exception".
String error        = null;
Exception exception = null;

// We will store the name for the entry to be deleted in this variable.
String name = null;

// We will first attempt to get the reference to the address book from the
// session. The "list.jsp" page sets this attribute in the session.
UserManager userHome = (UserManager) session.getAttribute("UserManager");
if (userHome == null) {
   error = "No connection with the User Manager established.";
} else {

   // Attempt to get the "id" parameter from the session
   name = request.getParameter("id");

   // If the name is null, then something is definitely wrong. When this page
   // is called from "list.jsp", the name is always specified.
   if (name == null) {
      error = "No name specified.";

   // Otherwise we will attempt to find and delete the entry
   } else {
      name = name.trim();

      try {
         userHome.remove(name);
      } catch (Exception e) {

         exception = e;
         error = "Caught \"" + exception.getClass().getName() +
                 "\" while attempting to remove the address entry with " +
                 "name \"" + name + "\".";
         errorStream.println(error);
         exception.printStackTrace(errorStream);
      }
   }
}

// Decide what the title will be.
String title;
if (error != null) {
   title = "Error";
} else {
   title = "AuthDB | Delete entry";
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<HTML>
<HEAD>
<TITLE><%= title %></TITLE>
</HEAD>
<BODY bgcolor="#FFFFFF">
<H1><%= title %></H1>

<%
   // If there was a fatal error, then display the error message
   if (error != null) {
%>

<P><BLOCKQUOTE><%= error %></BLOCKQUOTE>

<%
   // Otherwise display a message saying that the entry was deleted
   } else {
%>

<TABLE border="1" bgcolor="#FF2222">
<TR><TD><FONT color="#FFFFFF"><STRONG>Entry with id "<%= name %>" deleted.</STRONG></FONT></TD></TR>
</TABLE>

<%
   } /* else */
%>

<P><TABLE border="1">
<TR><TD><A href="list.jsp">Back&nbsp;to&nbsp;list</A></TD><TD><A href="./">Main menu</A></TD></TR>
</TABLE>
</BODY>
</HTML>
