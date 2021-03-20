#pragma once

enum token_type {
    WORD = 1,
    DOTDOT,
    LESSTHAN,
    GREATERTHAN,
    PIPE,
    DOUBLEQUOTES,
    BACKSLASH,
    AMPERSAND,

    SETENV,
    PRINTENV,
    UNSENTENV,
    HOME,
    HOME_PATH,
    CD,
    UNALIAS,
    ALIAS, /* alias w/o arguments lists all the current aliases w/ argument adds new alias command to the shell */
    BYE
};
