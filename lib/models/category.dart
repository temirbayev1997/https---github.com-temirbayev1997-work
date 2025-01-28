// enum Category {
//   all,
//   easy,
//   snowboard,
//   skates,
//   heavyEquipment,
//   street,
//   bicycle;

//   String get displayName {
//     switch (this) {
//       case Category.all:
//         return 'Все';
//       case Category.easy:
//         return 'Легкая Атлетика';
//       case Category.snowboard:
//         return 'Сноуборды';
//       case Category.skates:
//         return 'Коньки';
//       case Category.bicycle:
//         return 'Велосипеды';
//       case Category.heavyEquipment:
//         return "Тяжелые Инвентарь";
//       case Category.street:
//         return 'Уличный Спорт';
//     }
//   }
//   static Category fromString(String value) {
//     switch (value.toLowerCase()) {
//       case 'Уличный Спорт':
//         return Category.street;
//       case 'Тяжелая Инвентарь':
//         return Category.heavyEquipment;
//       case 'Легкая Атлетика':
//         return Category.easy;
//       case 'сноуборды':
//         return Category.snowboard;
//       case 'коньки':
//         return Category.skates;
//       case 'велосипеды':
//         return Category.bicycle;
//       default:
//         return Category.all;
//     }
//   }
// }
