'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('ServiceImages', [
      // Hair services images (Sarah - Service ID 1)
      {
        serviceId: 1,
        imageUrl: 'https://images.unsplash.com/photo-1562322140-8baeececf3df',
        caption: 'Modern layered haircut',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 1,
        imageUrl: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1',
        caption: 'Before and after transformation',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 1,
        imageUrl: 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f',
        caption: 'Styling process',
        createdAt: new Date(),
        updatedAt: new Date()
      },

      // Hair coloring images (Service ID 2)
      {
        serviceId: 2,
        imageUrl: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f',
        caption: 'Vibrant color results',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 2,
        imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e',
        caption: 'Color application process',
        createdAt: new Date(),
        updatedAt: new Date()
      },

      // Blowout images (Service ID 3)
      {
        serviceId: 3,
        imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035',
        caption: 'Perfect blowout finish',
        createdAt: new Date(),
        updatedAt: new Date()
      },

      // Manicure images (Michael - Service ID 4)
      {
        serviceId: 4,
        imageUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371',
        caption: 'Classic French manicure',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 4,
        imageUrl: 'https://images.unsplash.com/photo-1610992015732-2449b76344bc',
        caption: 'Nail art designs',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 4,
        imageUrl: 'https://images.unsplash.com/photo-1599948128020-9a44d1f0824b',
        caption: 'Cuticle care process',
        createdAt: new Date(),
        updatedAt: new Date()
      },

      // Pedicure images (Service ID 5)
      {
        serviceId: 5,
        imageUrl: 'https://images.unsplash.com/photo-1632345031435-8727f6897d53',
        caption: 'Relaxing pedicure treatment',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 5,
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
        caption: 'Foot massage therapy',
        createdAt: new Date(),
        updatedAt: new Date()
      },

      // Gel nails images (Service ID 6)
      {
        serviceId: 6,
        imageUrl: 'https://images.unsplash.com/photo-1607779097040-26e80aa78e66',
        caption: 'Gel nail application',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 6,
        imageUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371',
        caption: 'Long-lasting gel finish',
        createdAt: new Date(),
        updatedAt: new Date()
      },

      // Makeup services images (Emily - Service ID 7)
      {
        serviceId: 7,
        imageUrl: 'https://images.unsplash.com/photo-1503236823255-94609f598e71',
        caption: 'Natural everyday look',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 7,
        imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e',
        caption: 'Makeup application process',
        createdAt: new Date(),
        updatedAt: new Date()
      },

      // Special event makeup images (Service ID 8)
      {
        serviceId: 8,
        imageUrl: 'https://images.unsplash.com/photo-1526045478516-99145907023c',
        caption: 'Glamorous evening look',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 8,
        imageUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43',
        caption: 'Bold and dramatic styling',
        createdAt: new Date(),
        updatedAt: new Date()
      },

      // Bridal makeup images (Service ID 9)
      {
        serviceId: 9,
        imageUrl: 'https://images.unsplash.com/photo-1519699047748-de8e457a634e',
        caption: 'Bridal makeup perfection',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 9,
        imageUrl: 'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65',
        caption: 'Wedding day preparation',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        serviceId: 9,
        imageUrl: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2',
        caption: 'Bridal consultation',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('ServiceImages', null, {});
  }
};