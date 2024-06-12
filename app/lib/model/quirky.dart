class Quirky {
  List<String> quirks = [
    "Well, this category is as barren as a desert... but don't worry, our event oasis is just a mirage away!",
    "Hold your horses! This section is currently on a siesta, but rest assured, the event fiesta will resume shortly!",
    "This area is quieter than a mime in a library. Fear not, the events are just backstage, perfecting their entrance!",
    "Looks like this category pulled a disappearing act, but worry not! We're working on making it reappear with a bang!",
    "Did you hear that? No? Exactly! This category is so silent, even crickets are complaining. Let's spice it up with some events, shall we?",
    "Well, well, well... it seems this section is as eventful as a potato. Fear not, we're cooking up something exciting!",
    "This category is emptier than a cereal box on grocery day. Fear not, we're stocking up on events as we speak!",
    "Uh-oh! It's lonelier in here than the last slice of pizza at a party. Don't worry, we're ordering more events pronto!",
    "Well, this category is currently in stealth mode, quieter than a ninja in a library. Stay tuned for the grand event ninja reveal!",
    "Hold onto your hats! This section is as vacant as a ghost town in a spaghetti western. Ghost events are on their way to liven things up!",
    "Did you blink? Because you might've missed the events in this section. Don't worry, we're working on the slow-motion replay for you!",
    "Shhh... This category is napping, dreaming of exciting events. Let's wake it gently and make those dreams a reality!",
    "Alert: This zone is currently on a coffee break, but fear not, it will be back with a caffeine-fueled burst of events!",
    "Looks like this category is on vacation, sipping a virtual cocktail by the beach. We'll send a postcard when the events return!",
    "Echo...echo...echo... This section is quieter than an empty concert hall. The events are tuning their instruments for a grand symphony!",
  ];

  List<String> notifQuirks = [
    "Looks like this inbox is taking a nap. It's so quiet; you could hear a virtual pin drop. Is everyone on a notification siesta?",
    "The notification center is as serene as a meditation retreat. Either you've mastered digital Zen, or the notifications are plotting a surprise entrance.",
    "Not a single whisper in the notification realm. Either this app is on mute or the notifications are planning a grand entrance. Stay tuned!",
    "Zero notifications detected. Did the notification fairies go on vacation, or are they plotting a comeback for an epic surprise party?",
    "Inbox status: tumbleweeds. It's so deserted; you'd think notifications were on a sabbatical. Time to wake them up or join the tranquility!",
    "The notification habitat is eerily calm. Did the notifications decide to play hide-and-seek, or are they just enjoying a break from the limelight?",
    "Silence in the notification theater. Is this a feature film or an intermission? Either way, the notifications are backstage preparing for the next act!",
  ];
  List<String> searchQuirks = [
    "Whoops! Looks like our event compass lost its way in this search. How about we try a different route together?",
    "This search is as quiet as a library after closing hours. Let's explore other event avenues, shall we?",
    "Oh dear! It seems this search came up as empty as a magician's hat before the tricks. Let's conjure up another search?",
    "Well, this search is as barren as a desert before a rain dance. Let's sprinkle some new keywords and make it bloom!",
    "Oops-a-daisy! This search is as eventful as a snoozing sloth. How about we perk it up with a different query?",
    "Oh no, this search is as vacant as a haunted house during daylight. Let's ghost-hunt for some other keywords, shall we?",
    "Hmmm, it seems this search is as quiet as a mute mime. Let's add some buzzwords and make some noise!",
  ];

  String getQuirk() {
    return quirks[DateTime.now().microsecond % quirks.length];
  }

  String getSearchQuirk() {
    return searchQuirks[DateTime.now().microsecond % searchQuirks.length];
  }

  String getNotifQuirks() {
    return notifQuirks[DateTime.now().microsecond % notifQuirks.length];
  }
}
