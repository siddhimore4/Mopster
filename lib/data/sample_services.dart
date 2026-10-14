import 'package:flutter/material.dart';
import '../models/service_item.dart';

/// Central reusable data source for Mopster services.
/// NOTE: These sample prices are initial configurable examples for Dhule city.
/// They can be customized or loaded from a backend in the future.
class SampleServices {
  static const List<ServiceItem> allServices = [
    // ==========================================
    // 1. CLEANING SERVICES (Dhule Home Services)
    // ==========================================
    ServiceItem(
      id: 'clean_deep',
      title: 'Deep Home Cleaning',
      category: ServiceCategory.cleaning,
      shortDescription:
          'Intensive whole-home scrub, degreasing, and sanitization for total freshness.',
      fullDescription:
          'Complete end-to-end deep cleaning for your house in Dhule. Our trained staff handles hard-water stains, floor scrubbing with safe eco-friendly agents, ceiling fan wiping, cobweb removal, and switchboard care. Perfect before festivals, house warmings, or seasonal cleanups.',
      basePrice: 2499.0, // Configurable sample price
      duration: '4 - 5 hours',
      rating: 4.9,
      reviewCount: 142,
      inclusions: [
        'Floor mechanical scrubbing & wet mop',
        'Ceiling fans, light fixtures & switchboards dusting',
        'Doors, windows & glass pane washing',
        'Cabinet exterior & under-furniture dusting',
        'Full bathroom and kitchen sanitization',
      ],
      exclusions: [
        'Wall repainting or heavy repair work',
        'Appliance repair (refrigerator / AC mechanical repairs)',
      ],
      icon: Icons.cleaning_services_rounded,
      tag: 'Most Popular',
      isPopular: true,
    ),

    ServiceItem(
      id: 'clean_bathroom',
      title: 'Bathroom Cleaning',
      category: ServiceCategory.cleaning,
      shortDescription:
          'Descaling, tile stain removal, mirror polishing, and germ sanitization.',
      fullDescription:
          'Thorough cleaning and descaling of bathroom tiles, toilet bowl, taps, shower heads, and mirrors. Eliminates yellow stains, water marks, mold, and unpleasant odors, leaving your bathroom hygienic and fresh.',
      basePrice: 499.0, // Configurable sample price
      duration: '60 - 75 mins',
      rating: 4.8,
      reviewCount: 98,
      inclusions: [
        'Tile scrubbing & hard-water stain removal',
        'Toilet bowl, washbasin & shower descaling',
        'Mirror & glass partition streak-free wipe',
        'Drain declog inspection & deodorization',
      ],
      exclusions: [
        'Plumbing pipe replacement',
        'Grout replacement / re-tiling',
      ],
      icon: Icons.bathtub_rounded,
      tag: 'Best Value',
      isPopular: true,
    ),

    ServiceItem(
      id: 'clean_kitchen',
      title: 'Kitchen Cleaning',
      category: ServiceCategory.cleaning,
      shortDescription:
          'Degreasing stovetop, chimney surface, countertop, sink & cabinet wiping.',
      fullDescription:
          'Specialized kitchen cleaning designed for Indian cooking residues. Removes grease, oil splatters, and stubborn stains from the stove, chimney exteriors, tiled backsplash, and stainless steel sinks.',
      basePrice: 899.0, // Configurable sample price
      duration: '90 - 120 mins',
      rating: 4.8,
      reviewCount: 84,
      inclusions: [
        'Stovetop & gas burner degreasing',
        'Chimney outer surface wipe & filter rinse',
        'Tile backsplash scrub & oil removal',
        'Sink descaling & faucet shine',
        'Kitchen cabinet exterior wipe down',
      ],
      exclusions: [
        'Chimney motor dismantling / repairs',
        'Pest control chemical spraying',
      ],
      icon: Icons.countertops_rounded,
      tag: 'Kitchen Hero',
      isPopular: true,
    ),

    ServiceItem(
      id: 'clean_fullhome',
      title: 'Full-Home Cleaning',
      category: ServiceCategory.cleaning,
      shortDescription:
          'Standard comprehensive cleaning of living rooms, bedrooms, and common areas.',
      fullDescription:
          'A reliable, thorough cleaning service covering all living rooms, bedrooms, balconies, and entryways. Ideal for regular monthly hygiene maintenance for families across Dhule.',
      basePrice: 1699.0, // Configurable sample price
      duration: '3 - 4 hours',
      rating: 4.7,
      reviewCount: 110,
      inclusions: [
        'Living room & bedrooms sweeping & wet mopping',
        'Furniture surface dusting & vacuuming',
        'Balcony floor washing & railing wipe',
        'Doors, grilles & window sill dusting',
        'Trash disposal and freshener spray',
      ],
      exclusions: [
        'Terrace waterproofing',
        'Heavy furniture relocation outside the house',
      ],
      icon: Icons.home_work_rounded,
      tag: 'Family Favorite',
      isPopular: false,
    ),

    ServiceItem(
      id: 'clean_dusting',
      title: 'Dusting & General Cleaning',
      category: ServiceCategory.cleaning,
      shortDescription:
          'Quick touch-up cleaning: fan dusting, cobwebs, dry vacuuming, and mopping.',
      fullDescription:
          'Need your home spruced up before guests arrive? This express general cleaning takes care of ceiling cobwebs, dry dust on furniture, curtain dusting, and aromatic floor mopping.',
      basePrice: 599.0, // Configurable sample price
      duration: '90 mins',
      rating: 4.7,
      reviewCount: 65,
      inclusions: [
        'Ceiling cobweb removal from all rooms',
        'Sofa & upholstery dry dusting',
        'Fan blade and photo frame wipe down',
        'Fragrant disinfectant floor mop',
      ],
      exclusions: [
        'Wet shampooing of carpets or mattresses',
        'Deep chemical scrubbing',
      ],
      icon: Icons.dry_cleaning_rounded,
      tag: 'Express',
      isPopular: false,
    ),

    // ==========================================
    // 2. GARDENING SERVICES (Dhule Garden & Plant Care)
    // ==========================================
    ServiceItem(
      id: 'garden_care',
      title: 'Plant Care & Nourishment',
      category: ServiceCategory.gardening,
      shortDescription:
          'Nutrient feeding, organic pest spray, leaf wiping, and health diagnosis.',
      fullDescription:
          'Expert care for your balcony and terrace potted plants. Our Dhule gardening specialist inspects plant health, removes yellowing foliage, loosens topsoil, applies organic vermicompost, and sprays neem oil to prevent insects.',
      basePrice: 449.0, // Configurable sample price
      duration: '60 - 90 mins',
      rating: 4.9,
      reviewCount: 76,
      inclusions: [
        'Topsoil aeration (khurpi khodai)',
        'Organic compost / vermicompost top dressing',
        'Organic neem oil pest protection spray',
        'Dead leaves trimming & gentle leaf wash',
      ],
      exclusions: [
        'Purchase cost of newly added exotic plants',
        'Major drip irrigation pipe installation',
      ],
      icon: Icons.eco_rounded,
      tag: 'Top Rated',
      isPopular: true,
    ),

    ServiceItem(
      id: 'garden_cleanup',
      title: 'Garden Cleanup & Debris Removal',
      category: ServiceCategory.gardening,
      shortDescription:
          'Complete cleanup of dry leaves, weed removal, walkway clearing & garden tidying.',
      fullDescription:
          'Transforms overgrown and messy garden yards into clean, peaceful outdoor spaces. We pull out stubborn wild weeds, rake dry fallen leaves, edge stone pathways, and bag up organic yard waste neatly.',
      basePrice: 799.0, // Configurable sample price
      duration: '2 - 3 hours',
      rating: 4.8,
      reviewCount: 52,
      inclusions: [
        'Manual removal of wild weeds and thorny shrubs',
        'Dry leaf raking and courtyard sweeping',
        'Trimming runaway creepers and vines',
        'Collection and bagging of plant debris',
      ],
      exclusions: [
        'Tree felling (cutting down mature tree trunks)',
        'Construction debris / cement removal',
      ],
      icon: Icons.yard_rounded,
      tag: 'High Demand',
      isPopular: true,
    ),

    ServiceItem(
      id: 'garden_pruning',
      title: 'Plant & Shrub Pruning',
      category: ServiceCategory.gardening,
      shortDescription:
          'Artful shaping of shrubs, rose bushes, hedges, and flowering plants.',
      fullDescription:
          'Proper pruning stimulates fresh blooms and healthy branches. Handled with sterilized pruning shears, we shape your garden hedges, trim rose bushes for winter/spring flowering, and remove diseased stems safely.',
      basePrice: 599.0, // Configurable sample price
      duration: '90 - 120 mins',
      rating: 4.8,
      reviewCount: 43,
      inclusions: [
        'Hedge clipping & geometric shaping',
        'Rose bush deadheading and cut sealing',
        'Removal of deadwood and infected twigs',
        'Application of antifungal paste on cut edges',
      ],
      exclusions: [
        'Tall tree branch climbing beyond 10 feet',
        'Electrified power pole clearances',
      ],
      icon: Icons.content_cut_rounded,
      tag: 'Craftsman',
      isPopular: false,
    ),

    ServiceItem(
      id: 'garden_lawn',
      title: 'Lawn Maintenance & Mowing',
      category: ServiceCategory.gardening,
      shortDescription:
          'Uniform lawn mowing, edge border trimming, aeration, and grass fertilization.',
      fullDescription:
          'Keep your Dhule bungalow or society lawn green, soft, and uniformly cut. Includes grass cutting with calibrated mowers, precision border trimming near flower beds, and organic lawn feed application.',
      basePrice: 999.0, // Configurable sample price
      duration: '2 - 3 hours',
      rating: 4.7,
      reviewCount: 39,
      inclusions: [
        'Uniform grass mowing (up to 1,000 sq ft)',
        'Edging along sidewalks and flower borders',
        'Raking up grass clippings',
        'Lawn fertilizer application',
      ],
      exclusions: [
        'New lawn sod turf laying',
        'Excavator leveling',
      ],
      icon: Icons.grass_rounded,
      tag: 'Estate Favorite',
      isPopular: false,
    ),

    ServiceItem(
      id: 'garden_potting',
      title: 'Plant Potting & Repotting',
      category: ServiceCategory.gardening,
      shortDescription:
          'Transfer root-bound plants to fresh soil mix, terracotta pots, or planters.',
      fullDescription:
          'Plants stop growing when their roots choke in old, compacted soil. We prepare a premium potting mix (soil, coco peat, vermicompost, perlite), untangle root balls, and transplant your favorite plants into larger planters.',
      basePrice: 499.0, // Configurable sample price
      duration: '60 - 90 mins',
      rating: 4.9,
      reviewCount: 61,
      inclusions: [
        'Repotting up to 5 medium planters (labor & soil mixing)',
        'Root inspection & root rot treatment',
        'Drainage gravel layer addition',
        'Initial watering with seaweed extract tonic',
      ],
      exclusions: [
        'Supply of ceramic/designer pots (customer provides or pays separately)',
        'Purchase cost of exotic plant specimens',
      ],
      icon: Icons.local_florist_rounded,
      tag: 'Plant Health',
      isPopular: false,
    ),
  ];

  /// Get cleaning services only
  static List<ServiceItem> get cleaningServices =>
      allServices.where((s) => s.category == ServiceCategory.cleaning).toList();

  /// Get gardening services only
  static List<ServiceItem> get gardeningServices =>
      allServices.where((s) => s.category == ServiceCategory.gardening).toList();

  /// Get popular services for home screen showcase
  static List<ServiceItem> get popularServices =>
      allServices.where((s) => s.isPopular).toList();

  /// Find service by ID
  static ServiceItem? getById(String id) {
    try {
      return allServices.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
