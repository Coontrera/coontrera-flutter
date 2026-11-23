# Coontrera Mobile

App Flutter da Clínica Coontrera (Pilates e Fisioterapia), rebuild mobile do site institucional com um novo sistema de agendamento. **Todo o backend é mockado** (autenticação, usuários, agendamentos, disponibilidade) usando armazenamento local com Hive, seguindo interfaces de repositório que podem ser trocadas por chamadas HTTP reais no futuro sem alterar a UI.

## Contas de demonstração

| Papel  | E-mail                  | Senha        |
|--------|--------------------------|--------------|
| Admin  | admin@coontrera.com      | Admin@123    |
| Cliente| cliente@coontrera.com    | Cliente@123  |

Os dados são semeados automaticamente no primeiro uso (serviços, horários padrão, clientes de exemplo e alguns agendamentos) e persistem localmente entre reinicializações.

## Funcionalidades

- **Institucional**: Início, Serviços, Sobre Nós, Contato — conteúdo migrado do site original.
- **Cliente**: agendamento de consultas (serviço → data/horário → confirmação), histórico de agendamentos com cancelamento, perfil.
- **Admin**: calendário mensal com todos os agendamentos, confirmar/cancelar/concluir consultas, gerenciar horários e bloquear datas, listagem de clientes.

## Arquitetura

- **Estado**: Riverpod (`flutter_riverpod`)
- **Rotas**: `go_router` com guards de autenticação/papel
- **Persistência local**: `hive` / `hive_flutter`
- **Camada de dados**: interfaces abstratas em `lib/data/repositories/` com implementações mock em `lib/data/repositories/mock/` — trocar por uma API real é uma questão de escrever novas implementações e atualizar os providers em `lib/data/providers/repository_providers.dart`.

## Rodando o projeto

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # gera os adapters do Hive
flutter run
```

## Vincular ao Firebase

O app abre em modo local antes da configuração. Para vincular o SDK ao seu projeto Firebase, execute uma vez na raiz do repositório:

1. Instale a [Firebase CLI](https://firebase.google.com/docs/cli) e entre com a conta que tem acesso ao projeto usando `firebase login`.
2. Instale a ferramenta de configuração com `dart pub global activate flutterfire_cli`.
3. Execute `flutterfire configure`, escolha seu projeto e selecione as plataformas que vai usar (Android, iOS, Web ou Windows). Confirme a substituição de `lib/firebase_options.dart` quando solicitado. A ferramenta preenche a chave de API e os identificadores de cada aplicativo.
4. Execute `flutter run` na plataforma configurada. Se o app já estava aberto, encerre a execução e inicie de novo.

Para usar um registro de app existente, o pacote Android é `com.coontrera.coontrera_mobile` e o bundle ID do iOS é `com.coontrera.coontreraMobile`. No Windows, se o terminal não reconhecer `flutterfire`, use `dart pub global run flutterfire_cli:flutterfire configure` no passo 3.

A vinculação inicializa o Firebase Core. O login, as contas de demonstração e os agendamentos continuam no Hive. Para sincronizá-los com o Firebase, será preciso integrar os respectivos repositórios com Authentication e Firestore.

## Testes

```
flutter analyze
flutter test
```
# coontrera-flutter
