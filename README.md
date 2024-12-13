Protected Page
Una solución integral para controlar el acceso en aplicaciones Flutter basadas en roles y permisos.

Índice
Instalación
Cómo Configurar la Librería
Configuración básica.
Configuración de roles, permisos y fallback global.
Proteger Widgets con AccessGuard
Proteger Rutas con GetX
Validación Asíncrona
Casos de Uso Avanzados
Mapa de Pasos para Implementación
Colaborar y Contribuir
Licencia
Instalación
Agregar Dependencia Local
Si usas la librería localmente, agrega esta línea en tu pubspec.yaml:

yaml
Copiar código
dependencies:
  protected_page:
    path: ../protected_page
Agregar Dependencia desde un Repositorio
Si publicas la librería en un repositorio remoto como GitHub:

yaml
Copiar código
dependencies:
  protected_page:
    git:
      url: https://github.com/tuusuario/protected_page.git
      ref: main
Ejecuta:
