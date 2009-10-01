package authdb;

import java.util.Collection;
import java.util.Set;

/**
 * This interface represents a user manager, which provides methods
 * for managing a collection of user entities.  This interface
 * is similar to the home interface of an EJB.
 */

public interface UserManager {
  /**
   * This method initializes the database tables.
   */
  void init();
  /**
   * This method creates a user object with the given fields.
   */
  User create(String id, String password, Set roles);
  /**
   * This method finds a user object with the given unique id.
   */
  User find(String id);
  /**
   * This method returns all user objects.
   */
  Collection findAll();
  /**
   * This method removes the user object with the given unique id.
   */
  void remove(String id);
  /**
   * This method updates the user object with the given unique key.
   */
  void update(String id, String password, Set roles);
}