# Coontrera Mobile

App Flutter da Clínica Coontrera (Pilates e Fisioterapia). Nas plataformas configuradas, o app usa Firebase Authentication e Cloud Firestore diretamente. Antes da vinculação, ele inicia em modo de demonstração local.

## Funcionalidades

- **Institucional**: Início, Serviços, Sobre Nós, Contato — conteúdo migrado do site original.
- **Cliente**: agendamento de consultas (serviço → data/horário → confirmação), histórico de agendamentos com cancelamento, perfil.
- **Admin**: calendário mensal com todos os agendamentos, confirmar/cancelar/concluir consultas, gerenciar horários e bloquear datas, listagem de clientes.

## Arquitetura

- **Estado**: Riverpod (`flutter_riverpod`)
- **Rotas**: `go_router` com guards de autenticação/papel
- **Persistência local**: `hive` / `hive_flutter`
- **Camada de dados**: os providers em `lib/data/providers/repository_providers.dart` selecionam os repositórios Firebase ou locais na inicialização. O catálogo institucional acompanha o aplicativo. As contas e consultas de demonstração ficam apenas no dispositivo.

## Rodando o projeto

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # gera os adapters do Hive
flutter run
```

## Vincular ao Firebase

As plataformas **Android, iOS, Web e Windows** já estão vinculadas ao projeto `coontrera-app` em `lib/firebase_options.dart` (com `android/app/google-services.json` configurado para Android). Em um projeto Firebase novo ou para reconfigurar/adicionar outras plataformas (como macOS e Linux), siga os passos abaixo:

1. Instale a [Firebase CLI](https://firebase.google.com/docs/cli) e entre com a conta que tem acesso ao projeto usando `firebase login`.
2. Instale a ferramenta de configuração com `dart pub global activate flutterfire_cli`.
3. Execute `flutterfire configure`, escolha seu projeto e selecione as plataformas que vai usar (Android, iOS, Web ou Windows). Confirme a substituição de `lib/firebase_options.dart` quando solicitado. A ferramenta preenche a chave de API e os identificadores de cada aplicativo.
4. No Firebase Console, em **Authentication → Sign-in method**, ative **E-mail/senha**. Em **Firestore Database**, crie o banco **(default)** em modo de produção e escolha a região.
5. Na raiz do repositório, execute `firebase deploy --only firestore:rules --project SEU_ID_DO_PROJETO`, substituindo o ID pelo mesmo projeto selecionado no passo 3. As regras acompanham o código em `firestore.rules`.
6. Execute `flutter run` na plataforma configurada. Se o app já estava aberto, encerre a execução e inicie de novo.

Para usar um registro de app existente, o pacote Android é `com.coontrera.coontrera_mobile` e o bundle ID do iOS é `com.coontrera.coontreraMobile`. No Windows, se o terminal não reconhecer `flutterfire`, use `dart pub global run flutterfire_cli:flutterfire configure` no passo 3. Para compilar no iOS em um Mac, execute novamente o `flutterfire configure` no macOS para gerar `ios/Runner/GoogleService-Info.plist`.

### Conferir a vinculação

Cadastre um cliente pelo app. O usuário aparece em **Authentication → Users** e os dados de perfil em **Firestore → profiles → UID**. Saia, entre novamente e teste a recuperação de senha. Depois reserve um horário e abra a agenda em outra conta para conferir a indisponibilidade. Os horários da clínica usam Brasília (UTC−3).

Para habilitar o painel administrativo, cadastre uma conta própria pelo app. No console do Firestore, localize seu UID em `profiles` e altere o campo `role` de `client` para `admin`. Saia e entre novamente. A promoção só pode ser feita por quem administra o projeto Firebase. Os motivos de bloqueio e os detalhes das consultas têm leitura restrita.

## Testes

```
flutter analyze
flutter test
```
