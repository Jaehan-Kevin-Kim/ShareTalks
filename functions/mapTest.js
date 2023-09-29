const abc = [1, 2, 3, 4, 5];
const newArray = [];
const def = [4, 5, 6, 7];
const qwe = abc.forEach((a) =>
  def.forEach((d) => {
    if (a === d) {
      newArray.push(a);
      //   continue;
    }
  }),
);
const asd = abc.map((a) => def.filter((d) => d === a));
const xz = abc.map((a) => def.forEach((d) => d === a));

const efd = abc.map((a) => false);
