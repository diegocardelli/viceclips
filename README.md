# VICECLIPS — versión pública conectable

Esta carpeta contiene una base funcional para una web pública con autenticación, base de datos y almacenamiento de videos compartido usando Supabase. El hosting recomendado es Vercel o Netlify.

## Antes de publicar
No está publicada todavía: hace falta crear el proyecto de Supabase y conectar sus claves públicas. No compartas nunca una clave `service_role`.

## 1. Crear backend gratuito en Supabase
1. Entrá en https://supabase.com y creá una cuenta/proyecto.
2. En el proyecto, abrí **SQL Editor** y ejecutá todo `supabase/schema.sql`.
3. En **Project Settings > API**, copiá el **Project URL** y la clave **anon/public**.
4. Pegalos en `config.js` en los campos `url` y `anonKey`.
5. En **Authentication > URL Configuration**, agregá el dominio de producción a Site URL y Redirect URLs una vez que lo tengas.

## 2. Probar localmente
Abrí la carpeta con un servidor estático (no hace falta compilar). Por ejemplo:
- VS Code: extensión Live Server → Open with Live Server.
- O ejecutá `python -m http.server 8000` dentro de esta carpeta y abrí http://localhost:8000.

## 3. Publicar en internet
1. Subí esta carpeta a un repositorio GitHub.
2. En https://vercel.com, importá el repositorio.
3. Framework preset: **Other**. Build command: vacío. Output directory: `.`.
4. Deploy. La web queda accesible por una URL pública de Vercel.
5. Volvé a Supabase y configurá esa URL en Authentication > URL Configuration.

## Funciones incluidas
- Registro e inicio de sesión por email/contraseña.
- Sesión persistente gestionada por Supabase Auth.
- Publicación de clips MP4/WebM/MOV de hasta 100 MB.
- Videos compartidos mediante bucket público.
- Feed público, búsqueda y filtros por categoría.
- Likes guardados en base de datos.

## Limitaciones de esta primera versión
- No incluye todavía perfiles editables, comentarios, seguidores, ranking real ni panel de moderación.
- Los likes se guardan, pero la interfaz aún no muestra el contador agregado.
- Los videos del bucket son públicos: cualquier visitante con el enlace puede verlos.
- Para una plataforma grande conviene añadir moderación, límites por usuario, protección anti-spam, CDN/transcodificación y políticas de retención.
- Configurá confirmación de email y límites de Auth antes de abrir el registro al público.
