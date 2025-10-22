import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalAuthDb {
  static final LocalAuthDb _i = LocalAuthDb._();
  LocalAuthDb._();
  factory LocalAuthDb() => _i;

  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    if (_db != null) return;
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'agrocore_auth.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (d, v) async {
        // SQLite tipos simplificados
        await d.execute('''
CREATE TABLE users (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  name          TEXT NOT NULL,
  username      TEXT,
  email         TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  is_active     INTEGER NOT NULL DEFAULT 1,
  last_login_at TEXT,
  created_at    TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT NOT NULL DEFAULT (datetime('now'))
);
''');

        await d.execute('''
CREATE TABLE roles (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL UNIQUE,
  description TEXT
);
''');

        await d.execute('''
CREATE TABLE user_roles (
  user_id  INTEGER NOT NULL,
  role_id  INTEGER NOT NULL,
  assigned_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, role_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE
);
''');

        await d.execute('''
CREATE TABLE refresh_tokens (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id     INTEGER NOT NULL,
  token       TEXT NOT NULL UNIQUE,
  expires_at  TEXT NOT NULL,
  revoked_at  TEXT,
  device_info TEXT,
  ip_address  TEXT,
  created_at  TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
''');

        // Semilla de roles
        await d.insert('roles', {'name':'admin','description':'Acceso total'});
        await d.insert('roles', {'name':'ingeniero','description':'Panel ingeniero'});
        await d.insert('roles', {'name':'agricultor','description':'Panel agricultor'});

        // Hash bcrypt para Admin@123 (el que nos diste)
        const hash = r'$2y$12$AO5JCzwBoATQ8JqXta4yGerjTRvllvP8r.tvrXfxAVBTIsa4kxSV6';

        // Usuarios
        final idAgr = await d.insert('users', {
          'name':'Juan Pérez','username':null,'email':'agricultor@test.com',
          'password_hash':hash,'is_active':1
        });
        final idIng = await d.insert('users', {
          'name':'María López','username':null,'email':'ingeniero@test.com',
          'password_hash':hash,'is_active':1
        });
        final idAdm = await d.insert('users', {
          'name':'Admin General','username':'admin@test.com','email':'admin@test.com',
          'password_hash':hash,'is_active':1
        });

        // Map rol -> id
        final roles = await d.query('roles');
        int rid(String n) => roles.firstWhere((r)=>r['name']==n)['id'] as int;

        // Asignaciones
        await d.insert('user_roles', {'user_id': idAgr, 'role_id': rid('agricultor')});
        await d.insert('user_roles', {'user_id': idIng, 'role_id': rid('ingeniero')});
        for (final r in ['admin','ingeniero','agricultor']) {
          await d.insert('user_roles', {'user_id': idAdm, 'role_id': rid(r)});
        }
      },
    );
  }
}
