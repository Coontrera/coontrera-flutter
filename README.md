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

## Testes

```
flutter analyze
flutter test
```
# coontrera-flutter
