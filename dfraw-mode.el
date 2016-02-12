;;; dfraw-mode.el --- Dwarf Fortress "raw" file major mode

;;; Commentary:
;;; A major mode for editing Dwarf Fortress's "raw" files, which are often
;;; used for modding and which specify various things not built in to the
;;; game.

;;; Code:
(defvar dfraw-font-lock-exocomment-header
  '(("\\`[^[:space:]]+$" (0 font-lock-preprocessor-face t))
    ("[^][]+" (0 font-lock-comment-face keep)))
  "Font-lock matchers for \"exocomments\" and the file header in Dwarf Fortress \"raw\" files.")

(defvar dfraw-font-lock-basic
  '(("\\(\\[\\)\\([A-Z0-9_]+\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     ("\\(:\\)\\([^][:]*\\)"
      (save-excursion
	(if (re-search-forward "\\]" (line-end-position) t)
            (point)
          nil))
      nil
      (1 font-lock-keyword-face t)
      (2 font-lock-string-face t)))
    ("\\]" (0 font-lock-keyword-face t)))
  "Basic font-lock matchers for Dwarf Fortress \"raw\" files.")

(defvar dfraw-font-lock-token-specific
  `(

    ;;; top level tokens
    
    ;; OBJECT token
    (,(concat
       "\\(\\[\\)\\(OBJECT\\)\\(:\\)\\("
       (regexp-opt
	'("BODY"
	  "BODY_DETAIL_PLAN"
	  "BUILDING"
	  "CREATURE"
	  "CREATURE_VARIATION"
	  "DESCRIPTOR_COLOR"
	  "DESCRIPTOR_PATTERN"
	  "DESCRIPTOR_SHAPE"
	  "ENTITY"
	  "GRAPHICS"
	  "INTERACTION"
	  "INORGANIC"
	  "ITEM"
	  "LANGUAGE"
	  "MATERIAL_TEMPLATE"
	  "PLANT"
	  "REACTION"
	  "TISSUE_TEMPLATE"))
       "\\)\\(\\]\\)")
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-type-face t)
     (5 font-lock-keyword-face t))
    
    ;; type tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("BODY"
	  "BODY_DETAIL_PLAN"
	  "BUILDING"
	  "CREATURE"
	  "CREATURE_VARIATION"
	  "COLOR"
	  "COLOR_PATTERN"
	  "SHAPE"
	  "ENTITY"
	  "GRAPHICS"
	  "INTERACTION"
	  "INORGANIC"
	  "ITEM_AMMO"
	  "ITEM_ARMOR"
	  "ITEM_FOOD"
	  "ITEM_GLOVES"
	  "ITEM_HELM"
	  "ITEM_INSTRUMENT"
	  "ITEM_PANTS"
	  "ITEM_SHIELD"
	  "ITEM_SHOES"
	  "ITEM_SIEGEAMMO"
	  "ITEM_TOOL"
	  "ITEM_TOY"
	  "ITEM_TRAPCOMP"
	  "ITEM_WEAPON"
	  "SYMBOL"
	  "WORD"
	  "TRANSLATION"
	  "MATERIAL_TEMPLATE"
	  "PLANT"
	  "REACTION"
	  "TISSUE_TEMPLATE"))
       "\\)\\(:\\)\\([A-Z0-9_]+\\)\\(\\]\\)")
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-function-name-face t)
     (5 font-lock-keyword-face t))
    
    ;;; AMMO subtokens
    
    ;; NAME token
    ("\\(\\[\\)\\(NAME\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-string-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-string-face t)
     (7 font-lock-keyword-face t))
    
    ;; CLASS token
    ("\\(\\[\\)\\(CLASS\\)\\(:\\)\\([A-Z0-9_]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-function-name-face t)
     (5 font-lock-keyword-face t))
    
    ;; SIZE/WEIGHT token
    ("\\(\\[\\)\\(SIZE\\|WEIGHT\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t))
    
    ;; ATTACK token
    ("\\(\\[\\)\\(ATTACK\\)\\(:\\)\\(BLUNT\\|EDGE\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-builtin-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t)
     (8 font-lock-constant-face t)
     (9 font-lock-keyword-face t)
     (10 font-lock-string-face t)
     (11 font-lock-keyword-face t)
     (12 font-lock-string-face t)
     (13 font-lock-keyword-face t)
     (14 font-lock-string-face t)
     (15 font-lock-keyword-face t)
     (16 font-lock-constant-face t)
     (17 font-lock-keyword-face t))
    
    ;; ATTACK_PREPARE_AND_RECOVER token
    ("\\(\\[\\)\\(ATTACK_PREPARE_AND_RECOVER\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t))

    ;;; world generation tokens
    
    ;; WORLD_GEN token
    ("\\(\\[\\)\\(WORLD_GEN\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t))
    
    ;; TITLE token
    ("\\(\\[\\)\\(TITLE\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-string-face t)
     (5 font-lock-keyword-face t))
    
    ;; DIM token
    ("\\(\\[\\)\\(DIM\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t))
    
    ;; EMBARK_POINTS token
    ("\\(\\[\\)\\(EMBARK_POINTS\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t))
    
    ;; END_YEAR token
    ("\\(\\[\\)\\(END_YEAR\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t))
    
    ;; BEAST_END_YEAR token
    ("\\(\\[\\)\\(BEAST_END_YEAR\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\(-1\\|[0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t))
    
    ;; REVEAL_ALL_HISTORY token
    ("\\(\\[\\)\\(REVEAL_ALL_HISTORY\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-builtin-face t)
     (5 font-lock-keyword-face t))
    
    ;; CULL_HISTORICAL_FIGURES token
    ("\\(\\[\\)\\(CULL_HISTORICAL_FIGURES\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-builtin-face t)
     (5 font-lock-keyword-face t))
    
    ;; terrain tokens
    (,(concat "\\(\\[\\)\\("
	      (regexp-opt
	       '("ELEVATION"
		 "RAINFALL"
		 "TEMPERATURE"
		 "DRAINAGE"
		 "VOLCANISM"
		 "SAVAGERY"))
	      "\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t)
     (8 font-lock-constant-face t)
     (9 font-lock-keyword-face t)
     (10 font-lock-constant-face t)
     (11 font-lock-keyword-face t))
    
    ;; mesh tokens
    (,(concat "\\(\\[\\)\\("
	      (regexp-opt
	       '("ELEVATION_FREQUENCY"
		 "RAIN_FREQUENCY"
		 "DRAINAGE_FREQUENCY"
		 "TEMPERATURE_FREQUENCY"
		 "SAVAGERY_FREQUENCY"
		 "VOLCANISM_FREQUENCY"))
	      "\\)\\(:\\)\\(1\\|2\\|3\\|4\\|5\\|6\\|\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-builtin-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t)
     (8 font-lock-constant-face t)
     (9 font-lock-keyword-face t)
     (10 font-lock-constant-face t)
     (11 font-lock-keyword-face t)
     (12 font-lock-constant-face t)
     (13 font-lock-keyword-face t)
     (14 font-lock-constant-face t)
     (15 font-lock-keyword-face t))

    ;; POLE token
    (,(concat
       "\\(\\[\\)\\(POLE\\)\\(:\\)\\("
       (regexp-opt
	'("NONE"
	  "NORTH_OR_SOUTH"
	  "NORTH_AND_OR_SOUTH"
	  "NORTH"
	  "SOUTH"
	  "NORTH_AND_SOUTH"))
       "\\)\\(\\]\\)")
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-builtin-face t)
     (5 font-lock-keyword-face t))
    
    ;; MINERAL_SCARCITY token
    ("\\(\\[\\)\\(MINERAL_SCARCITY\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t))
    
    ;; MEGABEAST_CAP and SEMIMEGABEAST_CAP tokens
    ("\\(\\[\\)\\(\\(?:SEMI\\)?MEGABEAST_CAP\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t))
    
    ;; *_NUMBER tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("TITAN_NUMBER"
	  "DEMON_NUMBER"
	  "NIGHT_TROLL_NUMBER"
	  "BOGEYMAN_NUMBER"
	  "VAMPIRE_NUMBER"
	  "WEREBEAST_NUMBER"
	  "SECRET_NUMBER"
	  "REGIONAL_INTERACTION_NUMBER"
	  "DISTURBANCE_INTERACTION_NUMBER"
	  "EVIL_CLOUD_NUMBER"
	  "EVIL_RAIN_NUMBER"))
       "\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t))
    
    ;; TITAN_ATTACK_TRIGGER token
    ("\\(\\[\\)\\(TITAN_ATTACK_TRIGGER\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t)
     (8 font-lock-constant-face t)
     (9 font-lock-keyword-face t))
    
    ;; GOOD_SQ_COUNTS and EVIL_SQ_COUNTS tokens
    ("\\(\\[\\)\\(?:\\(GOOD\\|EVIL\\)_SQ_COUNTS\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t)
     (8 font-lock-constant-face t)
     (9 font-lock-keyword-face t))
    
    ;; GENERATE_DIVINE_MATERIALS token
    ("\\(\\[\\)\\(GENERATE_DIVINE_MATERIALS\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-builtin-face t)
     (5 font-lock-keyword-face t))
    
    ;; *_MIN, *_MAX, *_MIN_SIZE, and *_MAX_SIZE tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("PEAK_NUMBER_MIN"
	  "PARTIAL_OCEAN_EDGE_MIN"
	  "COMPLETE_OCEAN_EDGE_MIN"
	  "VOLCANO_MIN"
	  "CAVERN_LAYER_OPENNESS_MIN"
	  "CAVERN_LAYER_OPENNESS_MAX"
	  "CAVERN_LAYER_PASSAGE_DENSITY_MIN"
	  "CAVERN_LAYER_PASSAGE_DENSITY_MAX"
	  "CAVERN_LAYER_WATER_MIN"
	  "CAVERN_LAYER_WATER_MAX"
	  "CAVE_MIN_SIZE"
	  "CAVE_MAX_SIZE"
	  "MOUNTAIN_CAVE_MIN"
	  "NON_MOUNTAIN_CAVE_MIN"
	  "SUBREGION_MAX"))
       "\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-constant-face t)
     (5 font-lock-keyword-face t))
    
    ;; REGION_COUNTS token
    (,(concat
       "\\(\\[\\)\\(REGION_COUNTS\\)\\(:\\)\\("
       (regexp-opt
	'("SWAMP"
	  "DESERT"
	  "FOREST"
	  "MOUNTAINS"
	  "OCEAN"
	  "GLACIER"
	  "TUNDRA"
	  "GRASSLAND"
	  "HILLS"))
       "\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 font-lock-keyword-face t)
     (2 font-lock-builtin-face t)
     (3 font-lock-keyword-face t)
     (4 font-lock-builtin-face t)
     (5 font-lock-keyword-face t)
     (6 font-lock-constant-face t)
     (7 font-lock-keyword-face t)
     (8 font-lock-constant-face t)
     (9 font-lock-keyword-face t)
     (10 font-lock-constant-face t)
     (11 font-lock-keyword-face t))
    
    )
  "Token-specific font-lock matchers for Dwarf Fortress \"raw\" files.")

(defvar dfraw-font-lock-level1 (append dfraw-font-lock-exocomment-header
				       dfraw-font-lock-basic)
  "Font-lock level 1 for Dwarf Fortress \"raw\" files.")

(defvar dfraw-font-lock-level2 (append dfraw-font-lock-level1
				       dfraw-font-lock-token-specific)
  "Font-lock level 2 for Dwarf Fortress \"raw\" files.")

;;;###autoload
(define-derived-mode dfraw-mode
  fundamental-mode "DFRaw"
  "Major mode for working with Dwarf Fortress \"raw\" files"
  (setq-local font-lock-defaults '((dfraw-font-lock-level1
				    dfraw-font-lock-level2)
				   t)))

(provide 'dfraw-mode)
;;; dfraw-mode.el ends here
