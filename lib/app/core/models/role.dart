enum Role { agricultor, ingeniero, admin }

Role? roleFromString(String? s) {
  switch (s?.toLowerCase()) {
    case 'agricultor':
    case 'farmer':
      return Role.agricultor;
    case 'ingeniero':
    case 'engineer':
      return Role.ingeniero;
    case 'admin':
      return Role.admin;
    default:
      return null;
  }
}
