var 🎂 = ["🍰","🍰","🍰","🍰","🍰"]
for 🍰 in 🎂.slice(every: 2) {
    print(🍰)
}

let array = [ 1, 2, 3, 4, 5 ]
for slice in array.slice(every: 2) {
    print(slice)
}

let lazyArray = array.lazy.map(String.init)
for slice in lazyArray.slice(every: 2) {
    print(Array(slice))
}
