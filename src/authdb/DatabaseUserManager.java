package authdb;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * This class implements a database-backed user manager.
 */

public class DatabaseUserManager implements UserManager {

  private static final String USER_TABLE = "PRincipals";
  private static final String ROLE_TABLE = "ROles";
  private static final String DS_JNDI_NAME = "java:comp/env/jdbc/authdb";

  private String dsJndiName;

  /**
   * Constructs an instance using the default data source location.
   */
  public DatabaseUserManager() throws NamingException, SQLException {
    this(DS_JNDI_NAME);
  }

  /**
   * Constructs an instance using the specified data source location.
   * @throws javax.naming.NamingException if the data source cannot be found.
   */
  public DatabaseUserManager(String dsJndiName) throws NamingException {
    this.dsJndiName = dsJndiName;
  }
  
  public void init() {
    try {
      createTables();
      populateTables();
	} catch (NamingException e) {
		System.err.println("NamingException" + e.getMessage());
		throw new RuntimeException(e);
	}
  }
  
  /**
   * Attempts to (re)create the user and role database tables.
   * @throws javax.naming.NamingException if the data source cannot be found.
   */
  protected void createTables() throws NamingException {
    Connection connection = null;
    Statement stmt = null;	
    try {
      DataSource ds = null;
      InitialContext ctx = new InitialContext();
      ds = (DataSource) ctx.lookup(dsJndiName);
      connection = ds.getConnection();
      String[] statements = {
        "drop table " + ROLE_TABLE + " if exists",
        "drop table " + USER_TABLE + " if exists",
        "create table " + USER_TABLE + " (" +
        "PrincipalID varchar (255) not null, " +
        "Password varchar (255) not null," +
        "primary key (PrincipalID)" +
        ")",
        "create table " + ROLE_TABLE + " (" +
        "PrincipalID varchar (255) not null, " +
        "Role varchar (255)," +
        "RoleGroup varchar (255), " +
        "foreign key(PrincipalID) references Principals(PrincipalID)" +
        ")",
      };
      stmt = connection.createStatement();
      for (int i=0; i< statements.length; i++) {
        stmt.execute(statements[i]);
      }
    } catch (NamingException e1) {
      throw e1;
    } catch (SQLException e2) {
      // This is expected only if the tables already exist.
  	  System.err.println("SQLException " + e2.getMessage());
      System.out.println("DatabaseUserManager: problem creating tables");
    } finally {
      try {
      	if (stmt != null) { stmt.close(); }
        if (connection != null) { connection.close(); }
      } catch (SQLException e3) { }
    }
  }

  /**
   * Attempts to populate the tables with some default users.
   */
  protected void populateTables() throws NamingException {
    Connection connection = null;
    Statement stmt = null;
    try {
      DataSource ds = null;
      InitialContext ctx = new InitialContext();
      ds = (DataSource) ctx.lookup(dsJndiName);
      connection = ds.getConnection();
      String[] statements = {
        "insert into " + USER_TABLE + " values ('admin', 'password')",
        "insert into " + USER_TABLE + " values ('laufer', 'password')",
        "insert into " + USER_TABLE + " values ('user', 'password')",
        "insert into " + USER_TABLE + " values ('guest', 'password')",
        "insert into " + USER_TABLE + " values ('nobody', 'password')",
        "insert into " + ROLE_TABLE + " values ('admin', 'users', 'Roles')",
        "insert into " + ROLE_TABLE + " values ('admin', 'administrators', 'Roles')",
        "insert into " + ROLE_TABLE + " values ('admin', 'guests', 'Roles')",
        "insert into " + ROLE_TABLE + " values ('laufer', 'users', 'Roles')",
        "insert into " + ROLE_TABLE + " values ('laufer', 'guests', 'Roles')",
        "insert into " + ROLE_TABLE + " values ('user', 'users', 'Roles')",
        "insert into " + ROLE_TABLE + " values ('user', 'guests', 'Roles')",
        "insert into " + ROLE_TABLE + " values ('guest', 'guests', 'Roles')",
      };
      stmt = connection.createStatement();
      for (int i=0; i< statements.length; i++) {
        stmt.execute(statements[i]);
      }
    } catch (NamingException e1) {
      // This is expected only if the entries are already in the tables.
      throw e1;
    } catch (SQLException e2) {
  	  System.err.println("SQLException " + e2.getMessage());
      System.out.println("DatabaseUserManager: problem populating tables");
    } finally {
      try {
      	if (stmt != null) { stmt.close(); }
        if (connection != null) { connection.close(); }
      } catch (SQLException e3) { }
    }
  }

  public User create(String id, String password, Set roles) {
    Connection conn = null;
    PreparedStatement ps = null;

    try {
      InitialContext ctx = new InitialContext();
      DataSource ds = (DataSource) ctx.lookup(dsJndiName);
      conn = ds.getConnection();

      // define the prepared statement
      ps = conn.prepareStatement("INSERT INTO PRINCIPALS VALUES(?, ?)");
      // set the two parameter values
      ps.setString(1, id);
      ps.setString(2, password);
      // execute the statement
      ps.executeUpdate();
      ps.close();

      // insert an entry for each role this user has
      ps = conn.prepareStatement("INSERT INTO ROLES VALUES(?, ?, 'Roles')");
      Iterator i = roles.iterator();
      while (i.hasNext()) {
        String role = (String) i.next();
        ps.setString(1, id);
        ps.setString(2, role);
        ps.executeUpdate();
      }
      ps.close();

      System.out.println("DatabaseUserManager: created user " + id);
      return new DatabaseUser(id, password, roles);
    } catch(Exception ex) {
      ex.printStackTrace();
      return null;
    } finally {
      if (ps != null) {
        try {
          ps.close();
        } catch(SQLException e) { }
      }
      if (conn != null) {
        try {
          conn.close();
        } catch (Exception ex) { }
      }
    }
  }

  public User find(final String id) {
    Connection conn = null;
    PreparedStatement ps = null;

    try {
      InitialContext ctx = new InitialContext();
      DataSource ds = (DataSource) ctx.lookup(dsJndiName);
      conn = ds.getConnection();

      ps = conn.prepareStatement("select Password from Principals where PrincipalID = ?");
      ps.setString(1, id);
      ResultSet rs = ps.executeQuery();
      if (! rs.next()) {
        System.out.println("DatabaseUserManager: user " + id + " not found");
        return null;
      }
      final String password = rs.getString(1);
      System.out.println("DatabaseUserManager: found " + id + " " + password);
      ps.close();
      rs.close();

      ps = conn.prepareStatement("select Role from Roles where RoleGroup = 'Roles' and PrincipalID = ?");
      ps.setString(1, id);
      rs = ps.executeQuery();
      final Set roles = new HashSet();
      while (rs.next()) {
        final String role = rs.getString(1);
        System.out.println("DatabaseUserManager: found " + id + " " + role);
        roles.add(role);
      }
      ps.close();
      rs.close();

      System.out.println("DatabaseUserManager: found user " + id);
      return new DatabaseUser(id, password, roles);
    } catch(Exception ex) {
      ex.printStackTrace();
      return null;
    } finally {
      if (ps != null) {
        try {
          ps.close();
        } catch(SQLException e) { }
      }
      if (conn != null) {
        try {
          conn.close();
        } catch (Exception ex) { }
      }
    }
  }

  public Collection findAll() {
    Connection conn = null;
    final Map users = new HashMap();
    final Set result = new TreeSet();
    PreparedStatement ps = null;

    try {
      InitialContext ctx = new InitialContext();
      DataSource ds = (DataSource) ctx.lookup(dsJndiName);
      conn = ds.getConnection();

      ps = conn.prepareStatement("select PrincipalID, Password from Principals");
      ResultSet rs = ps.executeQuery();
      while (rs.next()) {
        final String id = rs.getString(1);
        final String password = rs.getString(2);
        System.out.println("DatabaseUserManager: found user " + id + " " + password);
        DatabaseUser user = new DatabaseUser(id, password, new HashSet()); 
        users.put(id, user);
        result.add(user);
      }
      ps.close();
      rs.close();
      
      ps = conn.prepareStatement("select PrincipalID, Role from Roles where RoleGroup = 'Roles'");
      rs = ps.executeQuery();
      while (rs.next()) {
        final String id = rs.getString(1);
        final String role = rs.getString(2);
        System.out.println("DatabaseUserManager: found role " + id + " " + role);
        ((DatabaseUser) users.get(id)).getRoles().add(role);
      }
      ps.close();
      rs.close();
      
    } catch(Exception ex) {
      return null;
    } finally {
      if (ps != null) {
        try {
          ps.close();
        } catch(SQLException e) { }
      }
      if (conn != null) {
        try {
          conn.close();
        } catch (Exception ex) { }
      }
    }

    return result;
  }

  public void remove(final String id) {
    Connection conn = null;
    PreparedStatement ps = null;

    try {
      InitialContext ctx = new InitialContext();
      DataSource ds = (DataSource) ctx.lookup(dsJndiName);
      conn = ds.getConnection();

      ps = conn.prepareStatement("delete from Roles where PrincipalID = ?");
      ps.setString(1, id);
      ps.executeUpdate();
      ps.close();

      ps = conn.prepareStatement("delete from Principals where PrincipalID = ?");
      ps.setString(1, id);
      ps.executeUpdate();
      ps.close();

      System.out.println("DatabaseUserManager: removed user " + id);
    } catch(Exception ex) {
      ex.printStackTrace();
    } finally {
      if (ps != null) {
        try {
          ps.close();
        } catch(SQLException e) { }
      }
      if (conn != null) {
        try {
          conn.close();
        } catch (Exception ex) { }
      }
    }
  }

  /**
   * This method updates the user with the given unique id.
   */
  public void update(String id, String password, Set roles) {
    System.out.println("DatabaseUserManager: updating user " + id + " " + password + " " + roles);
    Connection conn = null;
    PreparedStatement ps = null;

    try {
      InitialContext ctx = new InitialContext();
      DataSource ds = (DataSource) ctx.lookup(dsJndiName);
      conn = ds.getConnection();

      ps = conn.prepareStatement("update Principals set password = ? where PrincipalID = ?");
      ps.setString(1, password);
      ps.setString(2, id);
      ps.executeUpdate();
      ps.close();
      
      ps = conn.prepareStatement("delete from Roles where PrincipalID = ?");
      ps.setString(1, id);
      ps.executeUpdate();
      ps.close();

      ps = conn.prepareStatement("INSERT INTO ROLES VALUES(?, ?, 'Roles')");
      Iterator i = roles.iterator();
      while (i.hasNext()) {
        String role = (String) i.next();
        ps.setString(1, id);
        ps.setString(2, role);
        ps.executeUpdate();
      }
      ps.close();

      System.out.println("DatabaseUserManager: updated user " + id);
    } catch(Exception ex) {
      ex.printStackTrace();
    } finally {
      if (ps != null) {
        try {
          ps.close();
        } catch(SQLException e) { }
      }
      if (conn != null) {
        try {
          conn.close();
        } catch (Exception ex) { }
      }
    }
  }

  /**
   * A database-backed implementation of the user entity.
   * The setter methods update the corresponding fields locally
   * and in the database.  The entities are sorted in lexicographic
   * order by unique id.
   */
  private class DatabaseUser implements User, Comparable {
    private final String id;
    private String password;
    private Set roles;
    public DatabaseUser(String id, String password, Set roles) {
      this.id = id;
      this.password = password;
      this.roles = roles;
    }
    public String getId() { return id; }
    public synchronized String getPassword() {
      return password;
    }
    public synchronized void setPassword(String password) {
      if (! this.password.equals(password)) {
        this.password = password;
        DatabaseUserManager.this.update(id, password, roles);
      }
    }
    public synchronized Set getRoles() { return roles; }
    public synchronized void setRoles(Set roles) {
      if (! this.roles.equals(roles)) {
        this.roles = roles;
        DatabaseUserManager.this.update(id, password, roles);
      }
    }
    public int compareTo(Object that) {
      return this.id.compareTo(((User) that).getId());
    }
  }
}