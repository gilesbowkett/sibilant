module.exports = (function(module) {
  // module:required
  return (function() {
    for (var fName in module) (function() {
      return (function() {
        if (module.hasOwnProperty(fName)) {
          return (global)[fName] = (module)[fName];;
        };
      })();
    })();
  })();;
});

