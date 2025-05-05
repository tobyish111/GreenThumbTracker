//
//  TrefleFallbackSearch.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/29/25.
//

import Foundation


// Example lightweight fallback list
let fallbackPlants: [TreflePlant] = [
    TreflePlant(id: 1, slug: "aloe-vera", common_name: "Aloe Vera", scientific_name: "Aloe vera", image_url: "https://upload.wikimedia.org/wikipedia/commons/f/f3/Aloe_vera_flower.JPG", genus: "Aloe", family: "Asphodelaceae"),
    TreflePlant(id: 2, slug: "dracaena-trifasciata", common_name: "Snake Plant", scientific_name: "Dracaena trifasciata", image_url: nil, genus: "Dracaena", family: "Asparagaceae"),
    TreflePlant(id: 3, slug: "chlorophytum-comosum", common_name: "Spider Plant", scientific_name: "Chlorophytum comosum", image_url: nil, genus: "Chlorophytum", family: "Asparagaceae"),
    TreflePlant(id: 4, slug: "spathiphyllum-wallisii", common_name: "Peace Lily", scientific_name: "Spathiphyllum wallisii", image_url: nil, genus: "Spathiphyllum", family: "Araceae"),
    TreflePlant(id: 5, slug: "epipremnum-aureum", common_name: "Pothos", scientific_name: "Epipremnum aureum", image_url: nil, genus: "Epipremnum", family: "Araceae"),
    TreflePlant(id: 6, slug: "ficus-lyrata", common_name: "Fiddle Leaf Fig", scientific_name: "Ficus lyrata", image_url: nil, genus: "Ficus", family: "Moraceae"),
    TreflePlant(id: 7, slug: "zamioculcas-zamiifolia", common_name: "ZZ Plant", scientific_name: "Zamioculcas zamiifolia", image_url: nil, genus: "Zamioculcas", family: "Araceae"),
    TreflePlant(id: 8, slug: "chamaedorea-seifrizii", common_name: "Bamboo Palm", scientific_name: "Chamaedorea seifrizii", image_url: nil, genus: "Chamaedorea", family: "Arecaceae"),
    TreflePlant(id: 9, slug: "ficus-elastica", common_name: "Rubber Plant", scientific_name: "Ficus elastica", image_url: nil, genus: "Ficus", family: "Moraceae"),
    TreflePlant(id: 10, slug: "nephrolepis-exaltata", common_name: "Boston Fern", scientific_name: "Nephrolepis exaltata", image_url: nil, genus: "Nephrolepis", family: "Nephrolepidaceae"),
    TreflePlant(id: 11, slug: "hedera-helix", common_name: "English Ivy", scientific_name: "Hedera helix", image_url: nil, genus: "Hedera", family: "Araliaceae"),
    TreflePlant(id: 12, slug: "philodendron-hederaceum", common_name: "Philodendron", scientific_name: "Philodendron hederaceum", image_url: nil, genus: "Philodendron", family: "Araceae"),
    TreflePlant(id: 13, slug: "codiaeum-variegatum", common_name: "Croton", scientific_name: "Codiaeum variegatum", image_url: nil, genus: "Codiaeum", family: "Euphorbiaceae"),
    TreflePlant(id: 14, slug: "dypsis-lutescens", common_name: "Areca Palm", scientific_name: "Dypsis lutescens", image_url: nil, genus: "Dypsis", family: "Arecaceae"),
    TreflePlant(id: 15, slug: "crassula-ovata", common_name: "Jade Plant", scientific_name: "Crassula ovata", image_url: nil, genus: "Crassula", family: "Crassulaceae"),
    TreflePlant(id: 16, slug: "saintpaulia-ionantha", common_name: "African Violet", scientific_name: "Saintpaulia ionantha", image_url: nil, genus: "Saintpaulia", family: "Gesneriaceae"),
    TreflePlant(id: 17, slug: "lavandula-angustifolia", common_name: "Lavender", scientific_name: "Lavandula angustifolia", image_url: nil, genus: "Lavandula", family: "Lamiaceae"),
    TreflePlant(id: 18, slug: "ocimum-basilicum", common_name: "Basil", scientific_name: "Ocimum basilicum", image_url: nil, genus: "Ocimum", family: "Lamiaceae"),
    TreflePlant(id: 19, slug: "mentha-piperita", common_name: "Mint", scientific_name: "Mentha × piperita", image_url: nil, genus: "Mentha", family: "Lamiaceae"),
    TreflePlant(id: 20, slug: "salvia-rosmarinus", common_name: "Rosemary", scientific_name: "Salvia rosmarinus", image_url: nil, genus: "Salvia", family: "Lamiaceae"),
    TreflePlant(id: 21, slug: "thymus-vulgaris", common_name: "Thyme", scientific_name: "Thymus vulgaris", image_url: nil, genus: "Thymus", family: "Lamiaceae"),
    TreflePlant(id: 22, slug: "bellis-perennis", common_name: "Daisy", scientific_name: "Bellis perennis", image_url: nil, genus: "Bellis", family: "Asteraceae"),
    TreflePlant(id: 23, slug: "helianthus-annuus", common_name: "Sunflower", scientific_name: "Helianthus annuus", image_url: nil, genus: "Helianthus", family: "Asteraceae"),
    TreflePlant(id: 24, slug: "tagetes-erecta", common_name: "Marigold", scientific_name: "Tagetes erecta", image_url: nil, genus: "Tagetes", family: "Asteraceae"),
    TreflePlant(id: 25, slug: "tulipa-gesneriana", common_name: "Tulip", scientific_name: "Tulipa gesneriana", image_url: nil, genus: "Tulipa", family: "Liliaceae"),
    TreflePlant(id: 26, slug: "rosa-chinensis", common_name: "Rose", scientific_name: "Rosa chinensis", image_url: nil, genus: "Rosa", family: "Rosaceae"),
    TreflePlant(id: 27, slug: "phalaenopsis-amabilis", common_name: "Orchid", scientific_name: "Phalaenopsis amabilis", image_url: nil, genus: "Phalaenopsis", family: "Orchidaceae"),
    TreflePlant(id: 28, slug: "taraxacum-officinale", common_name: "Dandelion", scientific_name: "Taraxacum officinale", image_url: nil, genus: "Taraxacum", family: "Asteraceae"),
    TreflePlant(id: 29, slug: "carnegiea-gigantea", common_name: "Saguaro Cactus", scientific_name: "Carnegiea gigantea", image_url: nil, genus: "Carnegiea", family: "Cactaceae"),
    TreflePlant(id: 30, slug: "sedum-morganianum", common_name: "Burro's Tail", scientific_name: "Sedum morganianum", image_url: nil, genus: "Sedum", family: "Crassulaceae"),
    TreflePlant(id: 31, slug: "santolina-chamaecyparissus", common_name: "Lavender Cotton", scientific_name: "Santolina chamaecyparissus", image_url: nil, genus: "Santolina", family: "Asteraceae"),
    TreflePlant(id: 32, slug: "senecio-vulgaris", common_name: "Senecio", scientific_name: "Senecio vulgaris", image_url: nil, genus: "Senecio", family: "Asteraceae"),
    TreflePlant(id: 33, slug: "lobularia-maritima", common_name: "Sweet Alyssum", scientific_name: "Lobularia maritima", image_url: nil, genus: "Lobularia", family: "Brassicaceae")
       ]

