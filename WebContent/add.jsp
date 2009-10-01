<%@ page import="authdb.*,java.io.*,java.util.*" %>
<%

// Make sure this page will not be cached by the browser
response.addHeader("Pragma", "no-cache");
response.addHeader("Cache-Control", "no-store");

// We will send error messages to System.err, for verbosity. In a real
// application you will probably not want this.
PrintStream errorStream = System.err;

// If we find any fatal error, we will store it in this variable.
String error = null;

// In a moment we will check if the name, address and city were passed to this
// page. If they were not, then these variables will be set to contain the
// empty string ("").
String id       = "";
String password = "";
String role     = "";

// This variable indicates what function of this page is currently used. If
// this page is called with parameters, then a new user entry should be
// added. In that case this variable is true.
boolean submitting = false;

// We will first attempt to get the reference to the user from the
// session. The "list.jsp" page sets this attribute in the session.
UserManager userHome = (UserManager) session.getAttribute("UserManager");
if (userHome == null) {
   error = "No connection with the UserManager established.";
} else {

   // Attempt to get all 3 parameters from the session
   id = request.getParameter("id");
   password = request.getParameter("password");
   role = request.getParameter("role");

   // If all 3 parameters are specified, then this is probably a submission by
   // this very page. Note that if the user left one of the fields blank, then
   // the corresponding parameter will be "", not null.
   if (id != null && password != null && role != null) {
      id = id.trim();
      password = password.trim();
      role = role.trim();
      submitting = true;
   }
}

// In the following variable we will store a (non-fatal) warning message. This
// message will be displayed in the page, but so will the submission form.
String warning = null;

if (submitting) {
   warning = "";

   // If there is an empty name, address and/or city, then this will be noted
   // in the warning message.
   if ("".equals(id)) {
      warning = "No id specified. ";
   }
   if ("".equals(password)) {
      warning += "No password specified. ";
   }
   if ("".equals(role)) {
      warning += "No role specified.";
   }

   // If we don't have a warning message yet, then we will attempt to create
   // the new address entry.
   if ("".equals(warning)) {
      try {
         Set roles = new HashSet();
         StringTokenizer st = new StringTokenizer(role);
         while (st.hasMoreTokens()) {
           roles.add(st.nextToken());
         }
         userHome.create(id, password, roles);

         // We will only get here if the previous statement succeeded. If it
         // did succeed, then the fields on the page should be empty, and the
         // warning message will be set to null, for easy comparison checking
         // later on.
         id       = "";
         password = "";
         role     = "";

         // If we got this far, then there was no problem detected.
         warning = null;
      } catch (Exception e) {

         // Set the warning variable to indicate a problem.
         warning = "Unable to create new entry, caught: \"" +
                   e.getClass().getName() + "\", message is: \"" +
                   e.getMessage() + "\".";
      }
   }
}

// Decide what the title will be.
String title;
if (error != null) {
   title = "Error";
} else {
   title = "AuthDB | Add entry";
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
   // Otherwise display a table with fields to be filled in.
   } else {

      // If there was a warning, then display it.
      if (warning != null) {
%>

<TABLE border="1" bgcolor="#FF2222">
<TR><TD><FONT color="#FFFFFF"><STRONG>Warning:&nbsp;<%= warning %></STRONG></FONT></TD></TR>
</TABLE>

<%
      } /* if */

      // Display the table with fields. There are two columns. The left column
      // contains the names of the fields, while the right column contains the
      // fields.
%>

<FORM action="add.jsp" method="GET">
<P><TABLE border="1">
<TR>
   <TD><STRONG>Name:</STRONG></TD>
   <TD><INPUT type="text" name="id" value="<%= id %>"></INPUT></TD>
</TR>
<TR>
   <TD><STRONG>Password:</STRONG></TD>
   <TD><INPUT type="text" name="password" value="<%= password %>"></INPUT></TD>
</TR>
<TR>
   <TD><STRONG>Roles:</STRONG></TD>
   <TD><INPUT type="text" name="role" value="<%= role %>"></INPUT></TD>
</TR>
<TR>
   <TD colspan="3" align="center"><INPUT type="submit" value="Add this entry"></INPUT></TD>
</TR>
</TABLE>
</FORM>

<%
   } /* else */
%>

<P><TABLE border="1">
<TR><TD><A href="list.jsp">Back&nbsp;to&nbsp;list</A></TD><TD><A href="./">Main menu</A></TD></TR>
</TABLE>
</BODY>
</HTML>
