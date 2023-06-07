open Fun
open Clock

let is_stpaddy now = month now = 3 && (mday now ->. Math.between (17, 18))
let is_halloween now = month now = 10 && mday now >= 21