import Foundation

struct NodeTemplateField: Identifiable, Hashable {
    let id: String
    let label: String
    let placeholder: String
}

struct NodeTemplateDefinition {
    let helperText: String
    let fields: [NodeTemplateField]
}

struct FilledNodeTemplateField: Identifiable {
    let field: NodeTemplateField
    let value: String
    
    var id: String {
        field.id
    }
}

extension NodeCategory {
    var templateDefinition: NodeTemplateDefinition {
        switch self {
        case .character:
            return NodeTemplateDefinition(helperText: "Character traits that ground AI generations in a concrete person.", fields: [
                .init(id: "age", label: "Age", placeholder: "34"),
                .init(id: "race", label: "Race", placeholder: "Human, elf, android..."),
                .init(id: "height", label: "Height", placeholder: "5'9\""),
                .init(id: "weight", label: "Weight", placeholder: "160 lbs"),
                .init(id: "strengths", label: "Strengths", placeholder: "Clever, loyal, resourceful"),
                .init(id: "weaknesses", label: "Weaknesses", placeholder: "Impulsive, prideful, guarded"),
                .init(id: "core_desire", label: "Core Desire", placeholder: "What they want most"),
                .init(id: "core_fear", label: "Core Fear", placeholder: "What they dread losing or becoming")
            ])
        case .plot:
            return NodeTemplateDefinition(helperText: "Plot beats and pressure points the AI should respect.", fields: [
                .init(id: "premise", label: "Premise", placeholder: "The broad story setup"),
                .init(id: "inciting_incident", label: "Inciting Incident", placeholder: "What starts the plot"),
                .init(id: "primary_goal", label: "Primary Goal", placeholder: "What the story is pushing toward"),
                .init(id: "major_obstacle", label: "Major Obstacle", placeholder: "The biggest blocker"),
                .init(id: "stakes", label: "Stakes", placeholder: "What is lost if this fails"),
                .init(id: "twist", label: "Twist", placeholder: "Key reversal or surprise")
            ])
        case .conflict:
            return NodeTemplateDefinition(helperText: "Define the pressure, opposition, and cost at the heart of the conflict.", fields: [
                .init(id: "source", label: "Source", placeholder: "Who or what creates the conflict"),
                .init(id: "opposing_force", label: "Opposing Force", placeholder: "Main person, group, force, or belief"),
                .init(id: "internal_effect", label: "Internal Effect", placeholder: "How it wounds the character emotionally"),
                .init(id: "external_effect", label: "External Effect", placeholder: "How it disrupts the outer story"),
                .init(id: "stakes", label: "Stakes", placeholder: "What could be lost"),
                .init(id: "escalation_path", label: "Escalation Path", placeholder: "How this conflict gets worse")
            ])
        case .concept:
            return NodeTemplateDefinition(helperText: "Core idea prompts that shape abstract concepts into usable story material.", fields: [
                .init(id: "core_idea", label: "Core Idea", placeholder: "The concept in one sentence"),
                .init(id: "story_function", label: "Story Function", placeholder: "Why this concept matters in the novel"),
                .init(id: "genre_lens", label: "Genre Lens", placeholder: "How genre changes the concept"),
                .init(id: "theme_connection", label: "Theme Connection", placeholder: "What theme it supports"),
                .init(id: "symbolic_value", label: "Symbolic Value", placeholder: "What it represents underneath"),
                .init(id: "research_notes", label: "Research Notes", placeholder: "Facts, inspiration, or references")
            ])
        case .theme:
            return NodeTemplateDefinition(helperText: "Theme inputs help the AI write with philosophical and emotional cohesion.", fields: [
                .init(id: "central_question", label: "Central Question", placeholder: "What idea is being explored"),
                .init(id: "theme_statement", label: "Theme Statement", placeholder: "What the story seems to say"),
                .init(id: "counter_argument", label: "Counter Argument", placeholder: "The opposing truth or tension"),
                .init(id: "associated_image", label: "Associated Image", placeholder: "Recurring symbol or image"),
                .init(id: "emotional_flavor", label: "Emotional Flavor", placeholder: "Bittersweet, furious, hopeful..."),
                .init(id: "how_it_appears", label: "How It Appears", placeholder: "How readers feel it in the story")
            ])
        case .setting:
            return NodeTemplateDefinition(helperText: "World and place details that can anchor scene generation.", fields: [
                .init(id: "location", label: "Location", placeholder: "City, village, ship, kingdom..."),
                .init(id: "era", label: "Era", placeholder: "Time period or technological age"),
                .init(id: "climate", label: "Climate", placeholder: "Cold, humid, storm-season..."),
                .init(id: "culture", label: "Culture", placeholder: "Customs, beliefs, social habits"),
                .init(id: "rules", label: "Rules", placeholder: "Laws, social restrictions, magic limits"),
                .init(id: "sensory_signature", label: "Sensory Signature", placeholder: "Smells, sounds, textures, colors")
            ])
        case .scene:
            return NodeTemplateDefinition(helperText: "Scene objectives and beats to keep the AI focused on dramatic movement.", fields: [
                .init(id: "pov_character", label: "POV Character", placeholder: "Who carries the scene"),
                .init(id: "location", label: "Location", placeholder: "Where the scene takes place"),
                .init(id: "time", label: "Time", placeholder: "When the scene occurs"),
                .init(id: "goal", label: "Goal", placeholder: "What the character wants in the scene"),
                .init(id: "conflict", label: "Conflict", placeholder: "What blocks the goal"),
                .init(id: "outcome", label: "Outcome", placeholder: "How the scene ends or shifts")
            ])
        case .dialogue:
            return NodeTemplateDefinition(helperText: "Dialogue guidance for voice, purpose, and subtext.", fields: [
                .init(id: "speaker", label: "Speaker", placeholder: "Who is speaking"),
                .init(id: "listener", label: "Listener", placeholder: "Who they are speaking to"),
                .init(id: "surface_topic", label: "Surface Topic", placeholder: "What the conversation appears to be about"),
                .init(id: "subtext", label: "Subtext", placeholder: "What is really being said"),
                .init(id: "tone", label: "Tone", placeholder: "Tender, hostile, teasing, formal..."),
                .init(id: "desired_effect", label: "Desired Effect", placeholder: "What the speaker wants from the exchange")
            ])
        case .symbol:
            return NodeTemplateDefinition(helperText: "Symbol notes that help the AI reuse imagery with intention.", fields: [
                .init(id: "symbol_object", label: "Symbol Object", placeholder: "The object, creature, or image"),
                .init(id: "literal_role", label: "Literal Role", placeholder: "What it is in the world"),
                .init(id: "symbolic_meaning", label: "Symbolic Meaning", placeholder: "What it represents"),
                .init(id: "first_appearance", label: "First Appearance", placeholder: "Where it first shows up"),
                .init(id: "recurrence_pattern", label: "Recurrence Pattern", placeholder: "How it repeats"),
                .init(id: "evolution", label: "Evolution", placeholder: "How the meaning changes over time")
            ])
        case .motif:
            return NodeTemplateDefinition(helperText: "Repeated patterns the AI can weave through scenes and prose.", fields: [
                .init(id: "recurring_element", label: "Recurring Element", placeholder: "Image, phrase, action, color..."),
                .init(id: "meaning", label: "Meaning", placeholder: "What the motif suggests"),
                .init(id: "associated_character", label: "Associated Character", placeholder: "Who or what it follows"),
                .init(id: "frequency", label: "Frequency", placeholder: "How often it should reappear"),
                .init(id: "variation", label: "Variation", placeholder: "How it changes each time"),
                .init(id: "emotional_effect", label: "Emotional Effect", placeholder: "What it should make readers feel")
            ])
        case .foreshadowing:
            return NodeTemplateDefinition(helperText: "Foreshadowing clues the AI can plant without giving away the payoff.", fields: [
                .init(id: "clue", label: "Clue", placeholder: "The thing that hints at the future"),
                .init(id: "hidden_meaning", label: "Hidden Meaning", placeholder: "What the clue truly points toward"),
                .init(id: "payoff", label: "Payoff", placeholder: "What later event fulfills it"),
                .init(id: "placement", label: "Placement", placeholder: "Where the clue appears"),
                .init(id: "subtlety_level", label: "Subtlety Level", placeholder: "Barely noticeable, moderate, obvious"),
                .init(id: "misdirection", label: "Misdirection", placeholder: "How readers may misread it")
            ])
        case .resolution:
            return NodeTemplateDefinition(helperText: "Ending notes that help the AI close arcs with intention.", fields: [
                .init(id: "resolved_thread", label: "Resolved Thread", placeholder: "What storyline gets closed"),
                .init(id: "final_choice", label: "Final Choice", placeholder: "What defining decision is made"),
                .init(id: "emotional_payoff", label: "Emotional Payoff", placeholder: "How the ending should feel"),
                .init(id: "lasting_consequence", label: "Lasting Consequence", placeholder: "What remains changed"),
                .init(id: "loose_ends", label: "Loose Ends", placeholder: "What intentionally stays unresolved"),
                .init(id: "closing_image", label: "Closing Image", placeholder: "The last strong visual or line")
            ])
        case .climax:
            return NodeTemplateDefinition(helperText: "Climactic elements that sharpen pressure and decisive action.", fields: [
                .init(id: "decisive_moment", label: "Decisive Moment", placeholder: "What makes this the climax"),
                .init(id: "protagonist_choice", label: "Protagonist Choice", placeholder: "What they must choose"),
                .init(id: "antagonist_pressure", label: "Antagonist Pressure", placeholder: "How the opposition closes in"),
                .init(id: "stakes", label: "Stakes", placeholder: "What is on the line right now"),
                .init(id: "turning_point", label: "Turning Point", placeholder: "Where the tide shifts"),
                .init(id: "immediate_fallout", label: "Immediate Fallout", placeholder: "What happens moments after")
            ])
        case .exposition:
            return NodeTemplateDefinition(helperText: "Information-delivery choices that keep exposition dramatic.", fields: [
                .init(id: "information_to_reveal", label: "Information to Reveal", placeholder: "What the reader must learn"),
                .init(id: "source", label: "Source", placeholder: "Who or what reveals it"),
                .init(id: "audience", label: "Audience", placeholder: "Who within the story receives it"),
                .init(id: "timing", label: "Timing", placeholder: "When it should be revealed"),
                .init(id: "delivery_method", label: "Delivery Method", placeholder: "Dialogue, action, memory, artifact..."),
                .init(id: "hidden_tension", label: "Hidden Tension", placeholder: "What keeps it from feeling flat")
            ])
        case .risingAction:
            return NodeTemplateDefinition(helperText: "Escalation notes to help the AI build mounting momentum.", fields: [
                .init(id: "key_events", label: "Key Events", placeholder: "The major beats in this phase"),
                .init(id: "escalation", label: "Escalation", placeholder: "How pressure increases"),
                .init(id: "complication", label: "Complication", placeholder: "What makes things harder"),
                .init(id: "midpoint_shift", label: "Midpoint Shift", placeholder: "A meaningful reversal or reveal"),
                .init(id: "pressure_source", label: "Pressure Source", placeholder: "What keeps tension active"),
                .init(id: "character_change", label: "Character Change", placeholder: "How the cast evolves here")
            ])
        case .fallingAction:
            return NodeTemplateDefinition(helperText: "Aftermath notes for easing out of the climax without losing meaning.", fields: [
                .init(id: "aftermath", label: "Aftermath", placeholder: "What the world feels like after the climax"),
                .init(id: "consequences", label: "Consequences", placeholder: "What the climax cost"),
                .init(id: "emotional_reset", label: "Emotional Reset", placeholder: "How characters come down"),
                .init(id: "remaining_problem", label: "Remaining Problem", placeholder: "What still needs answering"),
                .init(id: "bridge_to_ending", label: "Bridge to Ending", placeholder: "How this leads to the final close"),
                .init(id: "quiet_image", label: "Quiet Image", placeholder: "A softer image or beat to land on")
            ])
        case .worldbuilding:
            return NodeTemplateDefinition(helperText: "Setting systems and rules the AI can consistently obey.", fields: [
                .init(id: "governing_rule", label: "Governing Rule", placeholder: "The big rule of the world"),
                .init(id: "social_structure", label: "Social Structure", placeholder: "Hierarchy, class, institutions"),
                .init(id: "technology_or_magic", label: "Technology or Magic", placeholder: "How power operates here"),
                .init(id: "history", label: "History", placeholder: "Important past shaping the present"),
                .init(id: "taboo", label: "Taboo", placeholder: "What people do not speak or act against"),
                .init(id: "daily_life_detail", label: "Daily Life Detail", placeholder: "A grounded everyday detail")
            ])
        case .subplot:
            return NodeTemplateDefinition(helperText: "Secondary-thread notes that help the AI connect subplots to the main narrative.", fields: [
                .init(id: "connected_main_thread", label: "Connected Main Thread", placeholder: "Which main story thread it touches"),
                .init(id: "subplot_goal", label: "Subplot Goal", placeholder: "What this subplot is pursuing"),
                .init(id: "core_tension", label: "Core Tension", placeholder: "What gives the subplot life"),
                .init(id: "key_beats", label: "Key Beats", placeholder: "Major subplot moments"),
                .init(id: "crossover_moment", label: "Crossover Moment", placeholder: "Where it collides with the main plot"),
                .init(id: "resolution", label: "Resolution", placeholder: "How the subplot closes")
            ])
        case .protagonist:
            return NodeTemplateDefinition(helperText: "Hero-facing traits and arc notes to guide focused generation.", fields: [
                .init(id: "role", label: "Role", placeholder: "Their story role or job"),
                .init(id: "want", label: "Want", placeholder: "What they consciously pursue"),
                .init(id: "need", label: "Need", placeholder: "What they truly need to learn"),
                .init(id: "flaw", label: "Flaw", placeholder: "The trait that complicates their journey"),
                .init(id: "arc", label: "Arc", placeholder: "How they change over the story"),
                .init(id: "moral_line", label: "Moral Line", placeholder: "What they refuse to cross")
            ])
        case .antagonist:
            return NodeTemplateDefinition(helperText: "Antagonist logic and leverage so the AI can create stronger opposition.", fields: [
                .init(id: "motive", label: "Motive", placeholder: "Why they do what they do"),
                .init(id: "plan", label: "Plan", placeholder: "How they pursue their agenda"),
                .init(id: "power", label: "Power", placeholder: "What advantage or influence they hold"),
                .init(id: "pressure_tactic", label: "Pressure Tactic", placeholder: "How they create pain or force choices"),
                .init(id: "blind_spot", label: "Blind Spot", placeholder: "The flaw they do not see"),
                .init(id: "relationship_to_protagonist", label: "Relationship to Protagonist", placeholder: "Personal tie to the hero")
            ])
        case .narrator:
            return NodeTemplateDefinition(helperText: "Narrative-delivery parameters for perspective and bias.", fields: [
                .init(id: "voice", label: "Voice", placeholder: "How the narration sounds"),
                .init(id: "reliability", label: "Reliability", placeholder: "Reliable, biased, deceptive..."),
                .init(id: "distance", label: "Distance", placeholder: "Close, medium, omniscient..."),
                .init(id: "audience", label: "Audience", placeholder: "Who the narrator seems to address"),
                .init(id: "bias", label: "Bias", placeholder: "What worldview colors the narration"),
                .init(id: "secret", label: "Secret", placeholder: "What the narrator is hiding or delaying")
            ])
        case .pointOfView:
            return NodeTemplateDefinition(helperText: "Point-of-view constraints that the AI should obey scene by scene.", fields: [
                .init(id: "pov_type", label: "POV Type", placeholder: "First person, close third, omniscient..."),
                .init(id: "viewpoint_character", label: "Viewpoint Character", placeholder: "Whose eyes we inhabit"),
                .init(id: "tense", label: "Tense", placeholder: "Past, present, mixed..."),
                .init(id: "access_limits", label: "Access Limits", placeholder: "What this POV cannot know"),
                .init(id: "blind_spots", label: "Blind Spots", placeholder: "Emotional or factual blind spots"),
                .init(id: "reason_for_choice", label: "Reason for Choice", placeholder: "Why this POV serves the story")
            ])
        case .tone:
            return NodeTemplateDefinition(helperText: "Tonal controls that help the AI keep the prose emotionally aligned.", fields: [
                .init(id: "tonal_quality", label: "Tonal Quality", placeholder: "Somber, witty, mythic, harsh..."),
                .init(id: "intensity", label: "Intensity", placeholder: "Low, restrained, heightened..."),
                .init(id: "influences", label: "Influences", placeholder: "Comparative moods or inspirations"),
                .init(id: "contrast", label: "Contrast", placeholder: "What tone it plays against"),
                .init(id: "scene_fit", label: "Scene Fit", placeholder: "Where this tone is strongest"),
                .init(id: "language_cues", label: "Language Cues", placeholder: "Specific diction or rhythm choices")
            ])
        case .mood:
            return NodeTemplateDefinition(helperText: "Reader-feeling targets that give scenes emotional atmosphere.", fields: [
                .init(id: "desired_feeling", label: "Desired Feeling", placeholder: "What the reader should feel"),
                .init(id: "trigger_images", label: "Trigger Images", placeholder: "Images that create the mood"),
                .init(id: "pacing_effect", label: "Pacing Effect", placeholder: "How the mood alters rhythm"),
                .init(id: "color_palette", label: "Color Palette", placeholder: "Colors associated with the mood"),
                .init(id: "sensory_cues", label: "Sensory Cues", placeholder: "Textures, sounds, smells, temperature"),
                .init(id: "reader_aftertaste", label: "Reader Aftertaste", placeholder: "The feeling left behind afterward")
            ])
        case .atmosphere:
            return NodeTemplateDefinition(helperText: "Environmental texture that the AI can use to saturate scenes.", fields: [
                .init(id: "environmental_feel", label: "Environmental Feel", placeholder: "Claustrophobic, sacred, rotten..."),
                .init(id: "weather_or_light", label: "Weather or Light", placeholder: "Rain, dusk, fluorescent glare..."),
                .init(id: "soundscape", label: "Soundscape", placeholder: "What the place sounds like"),
                .init(id: "textures", label: "Textures", placeholder: "Rough stone, slick glass, dry heat..."),
                .init(id: "tension_level", label: "Tension Level", placeholder: "How strained the environment feels"),
                .init(id: "contrast_element", label: "Contrast Element", placeholder: "One thing that breaks the atmosphere")
            ])
        case .backstory:
            return NodeTemplateDefinition(helperText: "Past-shaping details that help the AI write meaningful history.", fields: [
                .init(id: "past_event", label: "Past Event", placeholder: "The defining event"),
                .init(id: "when_it_happened", label: "When It Happened", placeholder: "Age, date, or period"),
                .init(id: "emotional_wound", label: "Emotional Wound", placeholder: "How it scarred the character"),
                .init(id: "who_was_involved", label: "Who Was Involved", placeholder: "People tied to the event"),
                .init(id: "lasting_effect", label: "Lasting Effect", placeholder: "What it still changes today"),
                .init(id: "reveal_timing", label: "Reveal Timing", placeholder: "When readers should learn it")
            ])
        case .flashback:
            return NodeTemplateDefinition(helperText: "Flashback structure so memory scenes stay purposeful.", fields: [
                .init(id: "trigger", label: "Trigger", placeholder: "What launches the flashback"),
                .init(id: "time_period", label: "Time Period", placeholder: "When the memory takes place"),
                .init(id: "memory_focus", label: "Memory Focus", placeholder: "What moment is being recalled"),
                .init(id: "purpose", label: "Purpose", placeholder: "Why the story needs this flashback"),
                .init(id: "pov", label: "POV", placeholder: "Whose perspective the flashback uses"),
                .init(id: "return_point", label: "Return Point", placeholder: "How the story lands back in the present")
            ])
        case .metaphor:
            return NodeTemplateDefinition(helperText: "Metaphorical pairings that help the AI write richer language.", fields: [
                .init(id: "source_image", label: "Source Image", placeholder: "The image used for comparison"),
                .init(id: "target_idea", label: "Target Idea", placeholder: "What the metaphor describes"),
                .init(id: "emotional_effect", label: "Emotional Effect", placeholder: "What the metaphor should evoke"),
                .init(id: "recurrence", label: "Recurrence", placeholder: "Whether it returns or stands alone"),
                .init(id: "contrast", label: "Contrast", placeholder: "What it pushes against"),
                .init(id: "clarity_level", label: "Clarity Level", placeholder: "Subtle, direct, surreal...")
            ])
        case .irony:
            return NodeTemplateDefinition(helperText: "Irony mechanics the AI can use to sharpen meaning or surprise.", fields: [
                .init(id: "irony_type", label: "Irony Type", placeholder: "Dramatic, situational, verbal..."),
                .init(id: "expectation", label: "Expectation", placeholder: "What seems like it should happen"),
                .init(id: "reality", label: "Reality", placeholder: "What actually happens"),
                .init(id: "target", label: "Target", placeholder: "Who or what the irony comments on"),
                .init(id: "emotional_result", label: "Emotional Result", placeholder: "Funny, tragic, bitter..."),
                .init(id: "reveal_moment", label: "Reveal Moment", placeholder: "When the irony lands")
            ])
        case .tension:
            return NodeTemplateDefinition(helperText: "Tension inputs for uncertainty, urgency, and reader pressure.", fields: [
                .init(id: "source", label: "Source", placeholder: "What generates the tension"),
                .init(id: "ticking_clock", label: "Ticking Clock", placeholder: "Deadline or countdown"),
                .init(id: "risk", label: "Risk", placeholder: "What can go wrong"),
                .init(id: "uncertainty", label: "Uncertainty", placeholder: "What no one knows for sure"),
                .init(id: "secret", label: "Secret", placeholder: "What is being hidden"),
                .init(id: "release_point", label: "Release Point", placeholder: "When the pressure breaks")
            ])
        case .pacing:
            return NodeTemplateDefinition(helperText: "Rhythm controls to guide speed, breath, and flow.", fields: [
                .init(id: "speed", label: "Speed", placeholder: "Fast, measured, slow-burn..."),
                .init(id: "sentence_feel", label: "Sentence Feel", placeholder: "Clipped, lyrical, uneven..."),
                .init(id: "scene_length", label: "Scene Length", placeholder: "Short bursts, long passages..."),
                .init(id: "acceleration_moment", label: "Acceleration Moment", placeholder: "Where things should speed up"),
                .init(id: "slowdown_moment", label: "Slowdown Moment", placeholder: "Where things should breathe"),
                .init(id: "rhythm_goal", label: "Rhythm Goal", placeholder: "How the section should feel overall")
            ])
        case .voice:
            return NodeTemplateDefinition(helperText: "Voice traits that make generated prose sound distinct.", fields: [
                .init(id: "diction", label: "Diction", placeholder: "Formal, blunt, poetic, streetwise..."),
                .init(id: "cadence", label: "Cadence", placeholder: "Short punches, long musical lines..."),
                .init(id: "worldview", label: "Worldview", placeholder: "How the speaker sees life"),
                .init(id: "signature_traits", label: "Signature Traits", placeholder: "Distinctive habits of speech"),
                .init(id: "influences", label: "Influences", placeholder: "Comparable voices or inspirations"),
                .init(id: "restraint", label: "Restraint", placeholder: "What the voice avoids or suppresses")
            ])
        case .style:
            return NodeTemplateDefinition(helperText: "Craft-level style controls for shaping generated prose.", fields: [
                .init(id: "prose_approach", label: "Prose Approach", placeholder: "Sparse, lush, crisp, ornate..."),
                .init(id: "sentence_structure", label: "Sentence Structure", placeholder: "Simple, winding, fragmented..."),
                .init(id: "imagery_density", label: "Imagery Density", placeholder: "Minimal, moderate, vivid..."),
                .init(id: "dialogue_style", label: "Dialogue Style", placeholder: "Naturalistic, stylized, compressed..."),
                .init(id: "narrative_texture", label: "Narrative Texture", placeholder: "Smooth, jagged, dreamy..."),
                .init(id: "avoidances", label: "Avoidances", placeholder: "Cliches or habits to avoid")
            ])
        case .genre:
            return NodeTemplateDefinition(helperText: "Genre promises and deviations that keep AI output on-brand.", fields: [
                .init(id: "primary_genre", label: "Primary Genre", placeholder: "Fantasy, noir, romance, sci-fi..."),
                .init(id: "subgenre", label: "Subgenre", placeholder: "Grimdark, cozy mystery, space opera..."),
                .init(id: "audience", label: "Audience", placeholder: "Adult, YA, crossover..."),
                .init(id: "core_promise", label: "Core Promise", placeholder: "What readers expect to get"),
                .init(id: "conventions", label: "Conventions", placeholder: "The tropes that should appear"),
                .init(id: "subversions", label: "Subversions", placeholder: "What expectations to twist")
            ])
        case .trope:
            return NodeTemplateDefinition(helperText: "Trope controls that let the AI use familiar beats intentionally.", fields: [
                .init(id: "trope_name", label: "Trope Name", placeholder: "Chosen one, rivals to lovers..."),
                .init(id: "expected_shape", label: "Expected Shape", placeholder: "How the trope normally plays out"),
                .init(id: "twist", label: "Twist", placeholder: "How this story changes it"),
                .init(id: "purpose", label: "Purpose", placeholder: "Why this trope belongs here"),
                .init(id: "associated_character", label: "Associated Character", placeholder: "Who carries the trope"),
                .init(id: "risk", label: "Risk", placeholder: "What could feel stale or predictable")
            ])
        case .archetype:
            return NodeTemplateDefinition(helperText: "Foundational role patterns that can guide character writing.", fields: [
                .init(id: "archetype_name", label: "Archetype Name", placeholder: "Mentor, trickster, ruler..."),
                .init(id: "strength", label: "Strength", placeholder: "What makes the archetype powerful"),
                .init(id: "flaw", label: "Flaw", placeholder: "Its common weakness"),
                .init(id: "modern_twist", label: "Modern Twist", placeholder: "How this version feels fresh"),
                .init(id: "story_function", label: "Story Function", placeholder: "What purpose it serves"),
                .init(id: "evolution", label: "Evolution", placeholder: "How it changes over time")
            ])
        case .emotion:
            return NodeTemplateDefinition(helperText: "Emotional details that can ground reactions and interiority.", fields: [
                .init(id: "core_emotion", label: "Core Emotion", placeholder: "Grief, desire, envy, relief..."),
                .init(id: "trigger", label: "Trigger", placeholder: "What brings it out"),
                .init(id: "physical_cues", label: "Physical Cues", placeholder: "How it manifests in the body"),
                .init(id: "coping_response", label: "Coping Response", placeholder: "How the character manages it"),
                .init(id: "contradiction", label: "Contradiction", placeholder: "Conflicting emotion underneath"),
                .init(id: "scene_impact", label: "Scene Impact", placeholder: "How it alters behavior or choices")
            ])
        case .relationship:
            return NodeTemplateDefinition(helperText: "Relational structure the AI can use to write chemistry and friction.", fields: [
                .init(id: "people_involved", label: "People Involved", placeholder: "Who is in the relationship"),
                .init(id: "bond_type", label: "Bond Type", placeholder: "Family, romantic, rivals, allies..."),
                .init(id: "history", label: "History", placeholder: "What shaped the relationship"),
                .init(id: "tension", label: "Tension", placeholder: "What strains or complicates it"),
                .init(id: "power_balance", label: "Power Balance", placeholder: "Who holds power and why"),
                .init(id: "defining_moment", label: "Defining Moment", placeholder: "A key event between them")
            ])
        case .memory:
            return NodeTemplateDefinition(helperText: "Memory details that help the AI write recall with consequence.", fields: [
                .init(id: "owner", label: "Owner", placeholder: "Who holds the memory"),
                .init(id: "memory_type", label: "Memory Type", placeholder: "Traumatic, nostalgic, fragmented..."),
                .init(id: "trigger", label: "Trigger", placeholder: "What brings it back"),
                .init(id: "accuracy", label: "Accuracy", placeholder: "Reliable, distorted, partial..."),
                .init(id: "emotional_charge", label: "Emotional Charge", placeholder: "How it feels to remember"),
                .init(id: "story_consequence", label: "Story Consequence", placeholder: "What changes because of it")
            ])
        case .dream:
            return NodeTemplateDefinition(helperText: "Dream logic that helps the AI generate surreal but purposeful material.", fields: [
                .init(id: "dreamer", label: "Dreamer", placeholder: "Who has the dream"),
                .init(id: "symbols", label: "Symbols", placeholder: "Important dream imagery"),
                .init(id: "emotional_tone", label: "Emotional Tone", placeholder: "Dread, wonder, longing..."),
                .init(id: "hidden_desire", label: "Hidden Desire", placeholder: "What wish or fear it reveals"),
                .init(id: "warning", label: "Warning", placeholder: "What threat or truth it hints at"),
                .init(id: "waking_effect", label: "Waking Effect", placeholder: "How the dream changes the day after")
            ])
        case .prophecy:
            return NodeTemplateDefinition(helperText: "Prophecy details the AI can use for omen, myth, and fulfillment.", fields: [
                .init(id: "who_prophesied", label: "Who Prophesied", placeholder: "The figure or force that gave the prophecy"),
                .init(id: "prophet", label: "Prophet", placeholder: "Who delivered or carries the prophecy"),
                .init(id: "date_of_prophecy", label: "Date of Prophecy", placeholder: "When it was spoken or recorded"),
                .init(id: "wording_or_omen", label: "Wording or Omen", placeholder: "The phrasing, sign, or image"),
                .init(id: "subject", label: "Subject", placeholder: "Who or what the prophecy concerns"),
                .init(id: "fulfillment_condition", label: "Fulfillment Condition", placeholder: "What must happen for it to come true")
            ])
        case .quest:
            return NodeTemplateDefinition(helperText: "Adventure and objective inputs for forward-driving story movement.", fields: [
                .init(id: "objective", label: "Objective", placeholder: "What must be achieved"),
                .init(id: "leader", label: "Leader", placeholder: "Who drives the quest"),
                .init(id: "allies", label: "Allies", placeholder: "Who helps"),
                .init(id: "obstacle", label: "Obstacle", placeholder: "The greatest barrier"),
                .init(id: "destination", label: "Destination", placeholder: "Where the quest leads"),
                .init(id: "reward_or_cost", label: "Reward or Cost", placeholder: "What is gained or sacrificed")
            ])
        case .transformation:
            return NodeTemplateDefinition(helperText: "Change-oriented inputs for arcs of becoming.", fields: [
                .init(id: "starting_state", label: "Starting State", placeholder: "Who or what exists at the start"),
                .init(id: "catalyst", label: "Catalyst", placeholder: "What triggers the change"),
                .init(id: "internal_shift", label: "Internal Shift", placeholder: "What changes inside"),
                .init(id: "external_shift", label: "External Shift", placeholder: "What changes visibly"),
                .init(id: "cost", label: "Cost", placeholder: "What must be given up"),
                .init(id: "final_state", label: "Final State", placeholder: "Who or what exists at the end")
            ])
        case .prompt:
            return NodeTemplateDefinition(helperText: "Prompt-shaping controls for AI-generated idea and prose outputs.", fields: [
                .init(id: "creative_brief", label: "Creative Brief", placeholder: "What you want the AI to make"),
                .init(id: "desired_output", label: "Desired Output", placeholder: "Scene, summary, profile, dialogue..."),
                .init(id: "style_cues", label: "Style Cues", placeholder: "Tone, voice, or prose influences"),
                .init(id: "constraints", label: "Constraints", placeholder: "What must or must not appear"),
                .init(id: "inspiration", label: "Inspiration", placeholder: "Images, references, or sparks"),
                .init(id: "target_length", label: "Target Length", placeholder: "Short, medium, 500 words...")
            ])
        }
    }
}

extension Node {
    var filledTemplateFields: [FilledNodeTemplateField] {
        category.templateDefinition.fields.compactMap { field in
            guard let rawValue = templateValues[field.id]?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !rawValue.isEmpty else {
                return nil
            }
            
            return FilledNodeTemplateField(field: field, value: rawValue)
        }
    }
}
