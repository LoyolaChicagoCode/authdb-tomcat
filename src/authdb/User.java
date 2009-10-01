package authdb;

import java.util.Set;

/**
 * This interface represents a user entity.
 */

public interface User {
  String getId();
  String getPassword();
  void setPassword(String password);
  Set getRoles();
  void setRoles(Set roles);
}