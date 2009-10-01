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

// In the following variable we will store a (non-fatal) warning message. This
// message will be displayed in the page, but so will the submission form.
String warning = null;

// In a moment we will check if the name, address and city were passed to this
// page. If they were not, then these variables will be set to contain the
// empty string ("").
String id    = "";
String password = "";
String role     = "";

// We will first attempt to get the reference to the address book from the
// session. The "list.jsp" page sets this attribute in the session.
UserManager userHome = (UserManager) session.getAttribute("UserManager");
if (userHome == null) {
  error = "No connection with the UserManager established.";
} else {

   // Attempt to get all 3 parameters from the session
   id       = request.getParameter("id");
   password = request.getParameter("password");
   role     = request.getParameter("role");

   // If all 3 parameters are specified, then this is probably a submission by
   // this very page. Note that if the user left one of the fields blank, then
   // the corresponding parameter will be "", not null.
   if (id != null && password != null && role != null) {
      id = id.trim();
      password = password.trim();
      role = role.trim();

      warning = "";
      if ("".equals(id)) {
         warning = "No id specified. ";
      }
      if ("".equals(password)) {
         warning += "No password specified. ";
      }
/*
      if ("".equals(role)) {
         warning += "No role specified.";
      }
*/
      if ("".equals(warning)) {
         warning = null;

         try {
            User entry = userHome.find(id);
            entry.setPassword(password);
            Set roles = new HashSet();
            StringTokenizer st = new StringTokenizer(role);
            while (st.hasMoreTokens()) {
              roles.add(st.nextToken());
            }
            entry.setRoles(roles);
         } catch (Exception e) {

            exception = e;
            error = "Caught \"" + exception.getClass().getName() +
                    "\" while attempting to get the user entry with " +
                    "id \"" + id + "\".";
            errorStream.println(error);
            exception.printStackTrace(errorStream);
         }
      }


   // If the name is null, then something is definitely wrong. When this page
   // is called from "list.jsp", the name is always specified.
   } else if (id == null) {
      error = "No id specified as a parameter.";

   // If only name is non-null, and address and city are null, then we will
   // attempt to obtain the address and city from the entity bean.
   } else {

      try {
         User entry = userHome.find(id);
         password = entry.getPassword();
         Collection roles = entry.getRoles();
         StringBuffer roleBuffer = new StringBuffer();
         Iterator i = roles.iterator();
         while (i.hasNext()) {
           roleBuffer.append(i.next());
           roleBuffer.append(" ");
         }
         role    = roleBuffer.toString().trim();
      } catch (Exception e) {

         exception = e;
         error = "Caught \"" + exception.getClass().getName() + "\" while " +
                 "attempting to get the address entry with id \"" + id +
                 "\".";
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
   title = "AuthDB | Edit entry";
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

<FORM action="edit.jsp" method="GET">
<INPUT type="hidden" name="id" value="<%= id %>"></INPUT>
<P><TABLE border="1">
<TR>
   <TD><STRONG>Id:</STRONG></TD>
   <TD><%= id %></TD>
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
   <TD colspan="3" align="center"><INPUT type="submit" value="Submit this entry"></INPUT></TD>
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
