import '../../core/constants/app_assets.dart';
import '../models/service.dart';

/// Seed content mirrored from the source web app (ServicesPage.jsx) so the
/// mocked app ships with real, accurate clinic copy instead of lorem ipsum.
abstract final class SeedData {
  static List<Service> services() => [
        Service(
          id: 'fisioterapia',
          title: 'Fisioterapia Personalizada',
          description:
              'A fisioterapia é uma ciência da saúde focada no estudo, prevenção e tratamento '
              'de distúrbios do movimento humano. Nosso objetivo é preservar, desenvolver ou '
              'restaurar a integridade de órgãos, sistemas ou funções, utilizando técnicas '
              'terapêuticas avançadas e personalizadas para promover sua saúde e bem-estar integral.',
          benefits: const [
            'Avaliação diagnóstica completa e individualizada',
            'Tratamento de lesões ortopédicas e esportivas',
            'Reabilitação neurológica e cardiorrespiratória',
            'Prevenção de disfunções e promoção da saúde funcional',
          ],
          ctaText: 'Agendar Avaliação',
          iconAsset: AppAssets.vetorFisio,
        ),
        Service(
          id: 'pilates',
          title: 'Pilates para Todos os Níveis',
          description:
              'O método Pilates oferece inúmeros benefícios para corpo e mente, trabalhando '
              'coordenação, flexibilidade, mobilidade, equilíbrio e postura. É indicado para '
              'todos, desde crianças a idosos, gestantes e pessoas com patologias específicas, '
              'adaptando-se a cada necessidade individual.',
          benefits: const [
            'Aumento da força central e tônus muscular global',
            'Melhora da flexibilidade e mobilidade articular',
            'Correção postural e alívio de dores crônicas',
            'Consciência corporal, respiração e bem-estar mental',
          ],
          ctaText: 'Agendar Aula Experimental',
          iconAsset: AppAssets.vetorPilates,
        ),
        Service(
          id: 'quiropraxia',
          title: 'Quiropraxia Clínica Avançada',
          description:
              'A quiropraxia clínica foca na manipulação articular da coluna e sistema '
              'musculoesquelético para tratar e prevenir problemas, aliviando dores, reduzindo '
              'risco de lesões e promovendo bem-estar. Reconhecida pela OMS, é uma abordagem '
              'eficaz para uma vida mais saudável e sem limitações.',
          benefits: const [
            'Alívio de dores na coluna (cervical, torácica, lombar)',
            'Tratamento de hérnias de disco, ciatalgia e dores de cabeça',
            'Correção de subluxações vertebrais e desalinhamentos',
            'Melhora da mobilidade geral e função do sistema nervoso',
          ],
          ctaText: 'Agendar Consulta',
          iconAsset: AppAssets.vetorQuiropraxia,
        ),
        Service(
          id: 'hidroterapia',
          title: 'Hidroterapia Revigorante',
          description:
              'Movimentos e exercícios terapêuticos em piscina aquecida estimulam a recuperação '
              'de lesões, trabalham a musculatura e fortalecem o corpo, ideal para reabilitação '
              'com baixo impacto, alívio de dores articulares e relaxamento profundo.',
          benefits: const [
            'Reabilitação de lesões ortopédicas e reumatológicas com baixo impacto',
            'Alívio de dores articulares, musculares e fibromialgia',
            'Melhora da circulação sanguínea e linfática, e relaxamento',
            'Fortalecimento muscular suave, progressivo e seguro',
          ],
          ctaText: 'Saber Mais sobre Hidroterapia',
          iconAsset: AppAssets.vetorHidroterapia,
        ),
        Service(
          id: 'liberacao',
          title: 'Liberação Miofascial',
          description:
              'Técnica terapêutica manual que visa aliviar dores musculares e tensões, '
              'melhorando a mobilidade e a flexibilidade através da aplicação de pressão em '
              'pontos específicos para liberar o tecido fibroso (fáscia) que reveste os músculos.',
          benefits: const [
            'Alívio de tensões, contraturas e nódulos musculares (pontos-gatilho)',
            'Aumento da flexibilidade, mobilidade e amplitude de movimento',
            'Melhora da circulação sanguínea local e recuperação muscular',
            'Prevenção de lesões e tratamento de dores crônicas',
          ],
          ctaText: 'Agendar Sessão',
          iconAsset: AppAssets.vetorLiberacao,
        ),
        Service(
          id: 'dryneedling',
          title: 'Dry Needling (Agulhamento a Seco)',
          description:
              'Técnica terapêutica minimamente invasiva que consiste na inserção de agulhas '
              'finas em pontos gatilho miofasciais para aliviar dores musculares e melhorar a '
              'mobilidade. É um tratamento rápido, seguro e eficaz para controlar lesões e '
              'inflamações musculoesqueléticas.',
          benefits: const [
            'Alívio rápido e eficaz de pontos gatilho e dores referidas',
            'Restauração da função muscular normal e relaxamento de bandas tensas',
            'Redução da inflamação local e melhora da microcirculação',
            'Complemento valioso a outras terapias manuais e reabilitação',
          ],
          ctaText: 'Consultar Especialista',
          iconAsset: AppAssets.vetorDry,
        ),
      ];
}
