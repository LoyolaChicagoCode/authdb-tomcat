<%@ page import="authdb.*,java.io.*,java.net.*,java.util.*" %>

<%

// Make sure this page will not be cached by the browser
response.addHeader("Pragma", "no-cache");
response.addHeader("Cache-Control", "no-store");

// We will send error messages to System.err, for verbosity. In a real
// application you will probably not want this.
PrintStream errorStream = System.err;

// If we find any fatal error, we will store it in the "error" variable. If
// an exception is caught that corresponds with this error message, then we
// will store it in the "exception" variable.
String error        = null;
Exception exception = null;

// First check if the reference to the EJB is already stored in the session.
UserManager userHome = (UserManager) session.getAttribute("UserManager");

// If not, then attempt to get the initial JNDI context.
if (userHome == null) {
  try {
    userHome = new DatabaseUserManager();
  } catch (Exception e) {
    exception = e;
    error = "Caught \"" + exception.getClass().getName() + "\" while " +
            "attempting to create User Manager entries.";
    errorStream.println(error);
    exception.printStackTrace(errorStream);
  }
  session.setAttribute("UserManager", userHome);
}


// This is the variable we will store the set of all user entries in. We
// convert this set from an instance of java.util.Collection to an Object
// array for easy iteration.
Object[] entries = null;
int entryCount = 0;

// The method that converts a Collection to an Object array needs a reference
// to the target return type. This is why we need an instance of an
// AddressEntry array.
final User[] emptyUserEntryArray = new User[] {};

if (error == null) {
   try {
      // Find all the user entries
      Collection entryCollection = userHome.findAll();

      entries = entryCollection.toArray(emptyUserEntryArray);
      if (entries == null) {
         entryCount = 0;
      } else {
         entryCount = entries.length;
      }
   } catch (Exception e) {
      exception = e;
      error = "Caught \"" + exception.getClass().getName() + "\" while " +
              "attempting to find all User entries.";
      errorStream.println(error);
      exception.printStackTrace(errorStream);
   }
}

// Decide what the title will be.
String title;
if (error != null) {
   title = "Error";
} else {
   title = "AuthDB | List of entries";
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
   // Display the error message, if any.
   if (error != null) {
%>

<P><BLOCKQUOTE><%= error %></BLOCKQUOTE>

<%
      // Display the exception message, if any.
      if (exception != null) {
%>

<P><BLOCKQUOTE><CODE><%= exception %></CODE></BLOCKQUOTE>

<%
      } /* if */

   } else {

      // If there are no entries to be displayed, display a descriptive text.
      if (entryCount == 0) {
%>

<P><BLOCKQUOTE>No entries found.</BLOCKQUOTE>

<%
      // Otherwise display a table with all entries and
      // display two extra choices: "Edit" and "Delete".
      } else {
%>

<P><TABLE border="1" width="100%">
<TR>
   <TD><STRONG>Id</STRONG></TD>
   <TD><STRONG>Password</STRONG></TD>
   <TD><STRONG>Roles</STRONG></TD>
   <TD><STRONG>Actions</STRONG></TD>
</TR>

<%
         for (int i=0; i<entryCount; i++) {
            User entry = (User) entries[i];
            String name        = entry.getId();
            String password    = entry.getPassword();
            Collection roles   = entry.getRoles();

            String encodedName = URLEncoder.encode(name);

            String editURL   = "edit.jsp?id="   + encodedName;
            String deleteURL = "delete.jsp?id=" + encodedName;
%>

<TR>
   <TD><%= name %></TD>
   <TD><%= password %></TD>
   <TD><%= roles %></TD>
   <TD><A href="<%= editURL %>">Edit</A>&nbsp;<A href="<%= deleteURL %>">Delete</A></TD>
</TR>

<%
         } /* for */
%>

</TABLE>

<%
      } /* else */
   } /* else */

   // Finally display a link to the page that allows the user to add an entry
   // to the user list.
%>

<P><TABLE border="1">
<TR><TD><A href="add.jsp">Add entry</A></TD><TD><A href="./">Main menu</A></TD></TR>
</TABLE>
</BODY>
</HTML>
