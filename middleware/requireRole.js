// Trusts the client-supplied x-role header outright - no token, no DB lookup.
// Matches the course's specified auth pattern (client claims a role, server believes it).
export default function requireRole(...allowedRoles) {
  return (req, res, next) => {
    const role = req.headers["x-role"];
    if (allowedRoles.includes(role)) {
      next();
    } else {
      res.status(403).json({ message: "You don't have permission to do this" });
    }
  };
}
