import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
//  SHARED COLOR PALETTE
// ─────────────────────────────────────────────
class _C {
  static const darkGreen = Color(0xFF1A2820);
  static const lightGreen = Color(0xFF5A8A6E);
  static const golden = Color(0xFF9D7E3F);
  static const cream = Color(0xFFD4C9A8);
  static const border = Color(0xFFB8A97A);
}

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
class UseCase {
  final String emoji;
  final String title;
  final String description;
  const UseCase({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class RiceRecommendation {
  final String name;
  final String imagePath; // asset path
  final String priceRange;
  final bool available;
  final String about;
  final List<UseCase> useCases;
  final Map<String, String> nutrition;
  final List<String> cookingTips;

  const RiceRecommendation({
    required this.name,
    required this.imagePath,
    required this.priceRange,
    required this.available,
    required this.about,
    required this.useCases,
    required this.nutrition,
    required this.cookingTips,
  });
}

// ─────────────────────────────────────────────
//  DEMO DATA  (replace with real AI response)
// ─────────────────────────────────────────────
final List<RiceRecommendation> _allRice = [
  RiceRecommendation(
    name: 'Sella Rice',
    imagePath: 'assets/images/rice.jpeg',
    priceRange: 'Rs 220–270/kg',
    available: true,
    about:
        'Parboiled rice that\'s partially cooked in the husk, giving it a golden hue '
        'and firmer texture. Retains more nutrients than regular white rice.',
    useCases: const [
      UseCase(
        emoji: '🍚',
        title: 'Everyday Meals',
        description:
            'Economical choice for daily consumption. Doesn\'t stick together easily.',
      ),
      UseCase(
        emoji: '🪔',
        title: 'Zarda (Sweet Rice)',
        description:
            'Traditional choice for sweet rice preparations. Absorbs color and syrup well.',
      ),
      UseCase(
        emoji: '🍱',
        title: 'Bulk Cooking',
        description:
            'Ideal for catering and large gatherings. Stays separate even when reheated.',
      ),
      UseCase(
        emoji: '🥘',
        title: 'Rice & Lentils (Khichdi)',
        description: 'Perfect for comfort food dishes combined with lentils.',
      ),
    ],
    nutrition: {
      'Calories': '194 per cup',
      'Protein': '5.1g per cup',
      'Carbohydrates': '41g per cup',
      'Fiber': 'Higher than white rice',
    },
    cookingTips: [
      'Requires less water than regular rice – use 1:1.25 ratio',
      'No need for extensive soaking – 15 minutes is enough',
      'Cooks faster than white Basmati',
      'Grains remain firm and separate',
      'Ideal for meal prep – reheats well',
    ],
  ),
  RiceRecommendation(
    name: 'Basmati Rice',
    imagePath: 'assets/images/rice.jpeg',
    priceRange: 'Rs 280–320/kg',
    available: true,
    about:
        'Long-grain aromatic rice with a distinctive fragrance. Grains are slender, aged, '
        'and cook to a fluffy, non-sticky texture — perfect for biryani and pulao.',
    useCases: const [
      UseCase(
        emoji: '🍛',
        title: 'Biryani',
        description:
            'The gold standard for biryani. Grains stay long and separate after cooking.',
      ),
      UseCase(
        emoji: '🫕',
        title: 'Pulao',
        description:
            'Absorbs spices and broth beautifully while keeping its shape.',
      ),
      UseCase(
        emoji: '🍽️',
        title: 'Formal Occasions',
        description: 'Premium choice for weddings and special dinners.',
      ),
      UseCase(
        emoji: '🥗',
        title: 'Rice Salads',
        description: 'Non-sticky grains hold up perfectly in cold salads.',
      ),
    ],
    nutrition: {
      'Calories': '210 per cup',
      'Protein': '4.4g per cup',
      'Carbohydrates': '46g per cup',
      'Fiber': '0.6g per cup',
    },
    cookingTips: [
      'Soak for 30 minutes before cooking for best results',
      'Use 1:1.5 water-to-rice ratio',
      'Cook on low heat after boiling',
      'Rest for 5 minutes before fluffing',
      'Add a few drops of oil to keep grains separate',
    ],
  ),
  RiceRecommendation(
    name: 'Super Basmati',
    imagePath: 'assets/images/rice.jpeg',
    priceRange: 'Rs 300–350/kg',
    available: true,
    about:
        'An enhanced variety of Basmati with extra-long grains and an even more intense aroma. '
        'Preferred by top chefs and restaurants for premium dishes.',
    useCases: const [
      UseCase(
        emoji: '👨‍🍳',
        title: 'Restaurant-style Biryani',
        description:
            'Restaurant-grade fragrance and grain elongation. Doubles in length when cooked.',
      ),
      UseCase(
        emoji: '🫙',
        title: 'Dum Pukht',
        description:
            'Ideal for slow-cooked dum cooking – absorbs flavors deeply.',
      ),
      UseCase(
        emoji: '🌾',
        title: 'Export Quality',
        description: 'Meets international export standards for premium rice.',
      ),
    ],
    nutrition: {
      'Calories': '205 per cup',
      'Protein': '4.8g per cup',
      'Carbohydrates': '44g per cup',
      'Fiber': '0.7g per cup',
    },
    cookingTips: [
      'Soak 45 minutes for maximum elongation',
      'Use 1:1.75 water ratio',
      'Cook uncovered first 5 minutes then cover',
      'Season water with salt and whole spices',
      'Serve immediately for best aroma',
    ],
  ),
];

// ─────────────────────────────────────────────
//  AI RECOMMENDATION SCREEN  (list view)
// ─────────────────────────────────────────────
class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  List<RiceRecommendation> get _filtered => _allRice
      .where(
        (r) =>
            r.name.toLowerCase().contains(_query.toLowerCase()) ||
            r.useCases.any(
              (u) => u.title.toLowerCase().contains(_query.toLowerCase()),
            ),
      )
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.lightGreen, _C.golden],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ───────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 18, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: _C.darkGreen,
                          ),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: _C.darkGreen.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Title ─────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: _C.darkGreen,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      'Find the best rice for your recipe',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _C.darkGreen.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: _C.cream.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _C.border.withOpacity(0.55)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          color: _C.darkGreen,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search rice or recipe...',
                          hintStyle: TextStyle(
                            color: _C.darkGreen.withOpacity(0.5),
                            fontSize: 13.5,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: _C.darkGreen.withOpacity(0.7),
                            size: 20,
                          ),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: _C.darkGreen.withOpacity(0.6),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Rice cards list ───────────
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No rice found for "$_query"',
                          style: TextStyle(
                            color: _C.darkGreen.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) => _RiceCard(rice: _filtered[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RICE CARD  (tap → detail screen)
// ─────────────────────────────────────────────
class _RiceCard extends StatelessWidget {
  final RiceRecommendation rice;
  const _RiceCard({required this.rice});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => RiceSuggestionDetailScreen(rice: rice),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: _C.cream.withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: _C.darkGreen.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  rice.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _C.lightGreen.withOpacity(0.3),
                    child: const Icon(
                      Icons.grain,
                      size: 36,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rice.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _C.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _C.golden.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _C.golden.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            rice.priceRange,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _C.darkGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (rice.available)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2E7D32).withOpacity(0.4),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 11,
                                  color: Color(0xFF2E7D32),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Available',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rice.about,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: _C.darkGreen.withOpacity(0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: _C.darkGreen.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RICE SUGGESTION DETAIL SCREEN
// ─────────────────────────────────────────────
class RiceSuggestionDetailScreen extends StatelessWidget {
  final RiceRecommendation rice;
  const RiceSuggestionDetailScreen({Key? key, required this.rice})
    : super(key: key);

  Widget _sectionCard({required Widget child, EdgeInsets? padding}) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.cream.withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: _C.darkGreen.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  Widget _sectionTitle(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 17, color: _C.golden),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _C.darkGreen,
          letterSpacing: 0.2,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final bannerH = (sw * 0.50).clamp(160.0, 240.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.lightGreen, _C.golden],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Back ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 18, 0),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: _C.darkGreen,
                      ),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: _C.darkGreen.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // ── Hero image ─────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              SizedBox(
                                height: bannerH,
                                width: double.infinity,
                                child: Image.asset(
                                  rice.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: _C.lightGreen.withOpacity(0.4),
                                    child: const Center(
                                      child: Icon(
                                        Icons.grain,
                                        size: 64,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Dark overlay
                              Container(
                                height: bannerH,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      _C.darkGreen.withOpacity(0.72),
                                    ],
                                  ),
                                ),
                              ),
                              // Name + badges
                              Positioned(
                                left: 16,
                                bottom: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rice.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _heroBadge(
                                          rice.priceRange,
                                          Icons.attach_money,
                                        ),
                                        const SizedBox(width: 8),
                                        if (rice.available)
                                          _heroBadge(
                                            'Available',
                                            Icons.trending_up,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ── About ──────────────────
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              'About This Rice',
                              Icons.eco_outlined,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              rice.about,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: _C.darkGreen.withOpacity(0.82),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Best Used For ──────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
                        child: _sectionTitle(
                          'Best Used For',
                          Icons.restaurant_menu_outlined,
                        ),
                      ),
                      ...rice.useCases.map((u) => _UseCaseTile(u: u)),

                      // ── Nutrition ──────────────
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              'Nutritional Information',
                              Icons.monitor_heart_outlined,
                            ),
                            const SizedBox(height: 12),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.2,
                              children: rice.nutrition.entries.map((e) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: _C.cream.withOpacity(0.30),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _C.border.withOpacity(0.35),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        e.key,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: _C.darkGreen.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        e.value,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: _C.darkGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // ── Cooking Tips ───────────
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              'Cooking Tips',
                              Icons.water_drop_outlined,
                            ),
                            const SizedBox(height: 10),
                            ...rice.cookingTips.map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: _C.darkGreen.withOpacity(0.82),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Floating help button ───────────────
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {},
        backgroundColor: _C.cream,
        child: const Icon(Icons.help_outline, color: _C.darkGreen, size: 20),
      ),
    );
  }

  Widget _heroBadge(String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.38),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
//  USE CASE TILE
// ─────────────────────────────────────────────
class _UseCaseTile extends StatelessWidget {
  final UseCase u;
  const _UseCaseTile({required this.u});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.cream.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: _C.darkGreen.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _C.lightGreen.withOpacity(0.22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border.withOpacity(0.35)),
            ),
            child: Center(
              child: Text(u.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _C.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  u.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _C.darkGreen.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
