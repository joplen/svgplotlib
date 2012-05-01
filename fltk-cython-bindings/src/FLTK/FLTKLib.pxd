# -*- coding: utf-8 -*-
ctypedef unsigned char uchar
ctypedef unsigned long ulong
ctypedef unsigned int Fl_Char

cdef extern from *:
    ctypedef char *const_char_ptr "const char *"
    ctypedef char **const_char_ptr_ptr "const char * const *"
    
cdef extern from "FL/Enumerations.H":
    ctypedef enum Fl_Event:
        pass
    
    int FL_NO_EVENT
    int FL_PUSH
    int FL_RELEASE
    int FL_ENTER
    int FL_LEAVE
    int FL_DRAG
    int FL_FOCUS
    int FL_UNFOCUS
    int FL_KEYDOWN
    int FL_KEYBOARD
    int FL_KEYUP
    int FL_CLOSE
    int FL_MOVE
    int FL_SHORTCUT
    int FL_DEACTIVATE
    int FL_ACTIVATE
    int FL_HIDE
    int FL_SHOW
    int FL_PASTE
    int FL_SELECTIONCLEAR
    int FL_MOUSEWHEEL
    int FL_DND_ENTER
    int FL_DND_DRAG
    int FL_DND_LEAVE
    int FL_DND_RELEASE
    
    ctypedef enum Fl_When:
        pass
    
    int FL_WHEN_NEVER
    int FL_WHEN_CHANGED
    int FL_WHEN_NOT_CHANGED
    int FL_WHEN_RELEASE
    int FL_WHEN_RELEASE_ALWAYS
    int FL_WHEN_ENTER_KEY
    int FL_WHEN_ENTER_KEY_ALWAYS
    int FL_WHEN_ENTER_KEY_CHANGED
    
    ctypedef enum Fl_Boxtype:
        pass
    
    int FL_NO_BOX
    int FL_FLAT_BOX
    int FL_UP_BOX
    int FL_DOWN_BOX
    int FL_UP_FRAME
    int FL_DOWN_FRAME
    int FL_THIN_UP_BOX
    int FL_THIN_DOWN_BOX
    int FL_THIN_UP_FRAME
    int FL_THIN_DOWN_FRAME
    int FL_ENGRAVED_BOX
    int FL_EMBOSSED_BOX
    int FL_ENGRAVED_FRAME
    int FL_EMBOSSED_FRAME
    int FL_BORDER_BOX
    int FL_SHADOW_BOX
    int FL_BORDER_FRAME
    int FL_SHADOW_FRAME
    int FL_ROUNDED_BOX
    int FL_RSHADOW_BOX
    int FL_ROUNDED_FRAME
    int FL_RFLAT_BOX
    int FL_ROUND_UP_BOX
    int FL_ROUND_DOWN_BOX
    int FL_DIAMOND_UP_BOX
    int FL_DIAMOND_DOWN_BOX
    int FL_OVAL_BOX
    int FL_OSHADOW_BOX
    int FL_OVAL_FRAME
    int FL_OFLAT_BOX
    
    # GL flags
    ctypedef enum Fl_Mode:
        pass
        
    int FL_RGB
    int FL_INDEX
    int FL_SINGLE
    int FL_DOUBLE
    int FL_ACCUM
    int FL_ALPHA
    int FL_DEPTH
    int FL_STENCIL
    int FL_RGB8
    int FL_MULTISAMPLE
    int FL_STEREO
    int FL_FAKE_SINGLE
  
    ctypedef unsigned int Fl_Color
    
    Fl_Color FL_FOREGROUND_COLOR
    Fl_Color FL_BACKGROUND2_COLOR
    Fl_Color FL_INACTIVE_COLOR
    Fl_Color FL_SELECTION_COLOR
    Fl_Color FL_GRAY0
    Fl_Color FL_DARK3
    Fl_Color FL_DARK2
    Fl_Color FL_DARK1
    Fl_Color FL_BACKGROUND_COLOR
    Fl_Color FL_LIGHT1
    Fl_Color FL_LIGHT2
    Fl_Color FL_LIGHT3
    Fl_Color FL_BLACK
    Fl_Color FL_RED
    Fl_Color FL_GREEN
    Fl_Color FL_YELLOW
    Fl_Color FL_BLUE
    Fl_Color FL_MAGENTA
    Fl_Color FL_CYAN
    Fl_Color FL_DARK_RED
    Fl_Color FL_DARK_GREEN
    Fl_Color FL_DARK_YELLOW
    Fl_Color FL_DARK_BLUE
    Fl_Color FL_DARK_MAGENTA
    Fl_Color FL_DARK_CYAN
    Fl_Color FL_WHITE
    
    Fl_Color fl_inactive(Fl_Color c)
    Fl_Color fl_contrast(Fl_Color fg, Fl_Color bg)
    Fl_Color fl_color_average(Fl_Color c1, Fl_Color c2, float weight)
    Fl_Color fl_lighter(Fl_Color c)
    Fl_Color fl_darker(Fl_Color c)
    Fl_Color fl_rgb_color(uchar r, uchar g, uchar b)
    
    ctypedef enum Fl_Labeltype:
        pass
    
    int FL_NORMAL_LABEL
    int FL_NO_LABEL
    int FL_SYMBOL_LABEL
    int FL_SHADOW_LABEL
    int FL_ENGRAVED_LABEL
    int FL_EMBOSSED_LABEL
    
    ctypedef unsigned Fl_Align
    
    Fl_Align FL_ALIGN_CENTER
    Fl_Align FL_ALIGN_TOP
    Fl_Align FL_ALIGN_BOTTOM
    Fl_Align FL_ALIGN_LEFT
    Fl_Align FL_ALIGN_RIGHT
    Fl_Align FL_ALIGN_INSIDE
    Fl_Align FL_ALIGN_TEXT_OVER_IMAGE
    Fl_Align FL_ALIGN_IMAGE_OVER_TEXT
    Fl_Align FL_ALIGN_CLIP
    Fl_Align FL_ALIGN_WRAP
    Fl_Align FL_ALIGN_IMAGE_NEXT_TO_TEXT
    Fl_Align FL_ALIGN_TEXT_NEXT_TO_IMAGE
    Fl_Align FL_ALIGN_IMAGE_BACKDROP
    Fl_Align FL_ALIGN_TOP_LEFT
    Fl_Align FL_ALIGN_TOP_RIGHT
    Fl_Align FL_ALIGN_BOTTOM_LEFT
    Fl_Align FL_ALIGN_BOTTOM_RIGHT
    Fl_Align FL_ALIGN_LEFT_TOP
    Fl_Align FL_ALIGN_RIGHT_TOP
    Fl_Align FL_ALIGN_LEFT_BOTTOM
    Fl_Align FL_ALIGN_RIGHT_BOTTOM
    Fl_Align FL_ALIGN_POSITION_MASK
    Fl_Align FL_ALIGN_IMAGE_MASK
    
    # Fonts
    ctypedef int Fl_Font
    
    Fl_Font FL_HELVETICA
    Fl_Font FL_HELVETICA_BOLD
    Fl_Font FL_HELVETICA_ITALIC
    Fl_Font FL_HELVETICA_BOLD_ITALIC
    Fl_Font FL_COURIER
    Fl_Font FL_COURIER_BOLD
    Fl_Font FL_COURIER_ITALIC
    Fl_Font FL_COURIER_BOLD_ITALIC
    Fl_Font FL_TIMES
    Fl_Font FL_TIMES_BOLD
    Fl_Font FL_TIMES_ITALIC
    Fl_Font FL_TIMES_BOLD_ITALIC
    Fl_Font FL_SYMBOL
    Fl_Font FL_SCREEN
    Fl_Font FL_SCREEN_BOLD
    Fl_Font FL_ZAPF_DINGBATS
    Fl_Font FL_FREE_FONT
    Fl_Font FL_BOLD 
    Fl_Font FL_ITALIC
    Fl_Font FL_BOLD_ITALIC
    
    ctypedef int Fl_Fontsize
    
    # keys & buttons
    int FL_Button
    int FL_BackSpace
    int FL_Tab
    int FL_Enter
    int FL_Pause
    int FL_Scroll_Lock
    int FL_Escape
    int FL_Home
    int FL_Left
    int FL_Up
    int FL_Right
    int FL_Down
    int FL_Page_Up
    int FL_Page_Down
    int FL_End
    int FL_Print
    int FL_Insert
    int FL_Menu
    int FL_Help
    int FL_Num_Lock
    int FL_KP
    int FL_KP_Enter
    int FL_KP_Last
    int FL_F
    int FL_F_Last
    int FL_Shift_L
    int FL_Shift_R
    int FL_Control_L
    int FL_Control_R
    int FL_Caps_Lock
    int FL_Meta_L
    int FL_Meta_R
    int FL_Alt_L
    int FL_Alt_R
    int FL_Delete
    
    int FL_LEFT_MOUSE
    int FL_MIDDLE_MOUSE
    int FL_RIGHT_MOUSE
    
    int FL_SHIFT
    int FL_CAPS_LOCK
    int FL_CTRL
    int FL_ALT
    int FL_NUM_LOCK
    int FL_META
    int FL_SCROLL_LOCK
    int FL_BUTTON1
    int FL_BUTTON2
    int FL_BUTTON3
    int FL_BUTTONS
    int FL_KEY_MASK
    int FL_COMMAND
    int FL_CONTROL

cdef extern from "FL/Fl_Image.H":
    cdef cppclass Fl_Image:
        int w()
        int h()
        int d()
        int ld()
        int count()
        Fl_Image *copy(int W, int H)
        Fl_Image *copy()
        
    cdef cppclass Fl_RGB_Image:
        Fl_RGB_Image(uchar *bits, int W, int H, int D, int LD)
        int w()
        int h()
        int d()
        const_char_ptr_ptr data()
        void color_average(Fl_Color c, float i)
        void inactive()
        void desaturate()
        void draw(int X, int Y, int W, int H, int cx, int cy)
        draw(int X, int Y)
        void uncache()
        
cdef extern from "FL/Fl_PNG_Image.H":
    cdef cppclass Fl_PNG_Image:
        Fl_PNG_Image(char* filename)

cdef extern from "FL/Fl_PNG_Image.H":
    cdef cppclass Fl_PNG_Image:
        Fl_PNG_Image(char* filename)

cdef extern from "FL/Fl_JPEG_Image.H":
    cdef cppclass Fl_JPEG_Image:
        Fl_JPEG_Image(char* filename)
        Fl_JPEG_Image(char *name, unsigned char *data)

cdef extern from "FL/Fl_Widget.H":
    ctypedef void (*Fl_Callback_p)(void *, void *)
    
    cdef cppclass Fl_Widget:
        void show()
        void hide()
        int x()
        int y()
        int w()
        int h()
        void resize(int x, int y, int w, int h)
        void position(int X,int Y)
        void size(int W,int H)
        Fl_When when()
        void when(uchar i)
        unsigned int changed()
        void set_changed()
        void clear_changed()
        unsigned int visible()
        int visible_r()
        unsigned int active()
        int active_r()
        void activate()
        void deactivate()
        void redraw()
        Fl_Color color()
        void color(Fl_Color bg)
        Fl_Color selection_color()
        void selection_color(Fl_Color a)
        Fl_Boxtype box()
        void box(Fl_Boxtype new_box)
        char* label()
        void copy_label(char* text)
        Fl_Align align()
        void align(Fl_Align alignment)
        Fl_Color labelcolor()
        void labelcolor(Fl_Color c)
        Fl_Font labelfont()
        void labelfont(Fl_Font f)
        Fl_Labeltype labeltype()
        void labeltype(Fl_Labeltype a)
        Fl_Fontsize labelsize()
        void labelsize(Fl_Fontsize pix)
        void measure_label(int& ww, int& hh)
        Fl_Image* image()
        void image(Fl_Image* img)
        Fl_Image* deimage()
        void deimage(Fl_Image* img)
        char *tooltip()
        void copy_tooltip(char *text)
        void callback(Fl_Callback_p cb, void* p)
        void* user_data()
    
cdef extern from "Helper.H":
    void set_input_hook()
    
    cdef cppclass Fl_Widget_:
        Fl_Widget_(int X, int Y, int W, int H, char *L, void *data)
    
    cdef cppclass Fl_Gl_Window_:
        Fl_Gl_Window_(int X, int Y, int W, int H, char *l, void *data)
        Fl_Gl_Window_(int W, int H, char *l, void *data)
        
        void flush()
        char valid()
        void valid(char v)
        void invalidate()
        char context_valid()
        void context_valid(char v)
        int can_do()
        Fl_Mode mode()
        int mode(int a)
        int mode(int *a)
        void *context()
        void context(void*, int destroy_flag)
        void make_current()
        void swap_buffers()
        void ortho()
        int can_do_overlay()
        void redraw_overlay()
        void hide_overlay()
        void make_overlay_current()
        
cdef extern from "FL/Fl_Group.H":
    cdef cppclass Fl_Group:
        Fl_Group(int,int,int,int, char *)
        int handle(int)
        void begin()
        void end()
        int children()
        void clear()
        void resizable(Fl_Widget *o)
        
cdef extern from "FL/Fl_Window.H":
    cdef cppclass Fl_Window:
        Fl_Window(int x, int y, int w, int h, char* title)
        Fl_Window(int w, int h, char* title)
        int handle(int)
        Fl_Window *parent()
        int children()
        Fl_Widget *child(int n)
        void size_range(int,int,int,int,int,int,int)
        void fullscreen()
        void fullscreen_off(int,int,int,int)
        void iconize()
        int x_root()
        int y_root()
        void make_current()
        void hide()
        void set_modal()
        unsigned int modal()
        void set_non_modal()
        void callback(Fl_Callback_p cb, void* p)
        void* user_data()

cdef extern from "FL/Fl_Double_Window.H":
    cdef cppclass Fl_Double_Window:
        Fl_Double_Window(int x, int y, int w, int h, char* title)
        Fl_Double_Window(int w, int h, char* title)
        Fl_Window *parent()
        
cdef extern from "FL/Fl_Gl_Window.H":
    cdef cppclass Fl_Gl_Window:
        pass
        
cdef extern from "FL/Fl_Button.H":
    cdef cppclass Fl_Button:
        Fl_Button(int X, int Y, int W, int H, char *L)
        int value(int v)
        char value()
        int set()
        int clear()
        void setonly()
        int shortcut()
        void shortcut(int s)

cdef extern from "FL/Fl_Check_Button.H":
    cdef cppclass Fl_Check_Button:
        Fl_Check_Button(int X, int Y, int W, int H, char *L)
        
cdef extern from "FL/Fl_Menu_.H":
    cdef cppclass Fl_Menu_:
        int value()
        int value(int v)
        int insert(int index, char* label, int shortcut, Fl_Callback_p, void*, int)
        int add(char* label, int shortcut, Fl_Callback_p, void*, int)
        int size()
        void size(int W, int H)
        void clear()
        int clear_submenu(int index)

cdef extern from "FL/Fl_Menu_Item.H":
    int FL_MENU_INACTIVE
    int FL_MENU_TOGGLE
    int FL_MENU_VALUE
    int FL_MENU_RADIO
    int FL_MENU_INVISIBLE
    int FL_SUBMENU_POINTER
    int FL_SUBMENU
    int FL_MENU_DIVIDER
    int FL_MENU_HORIZONTAL
        
cdef extern from "FL/Fl_Menu_Bar.H":
    cdef cppclass Fl_Menu_Bar:
        Fl_Menu_Bar(int X, int Y, int W, int H, char *l)
        int handle(int)

cdef extern from "FL/Fl_Menu_Button.H":
    cdef cppclass Fl_Menu_Button:
        Fl_Menu_Button(int X, int Y, int W, int H, char *l)

cdef extern from "FL/Fl_Tabs.H":
    cdef cppclass Fl_Tabs:
        Fl_Tabs(int X, int Y, int W, int H, char *l)
        Fl_Widget *value()
        int value(Fl_Widget *)
  

cdef extern from "FL/Fl_Choice.H":
    cdef cppclass Fl_Choice:
        Fl_Choice(int X, int Y, int W, int H, char *l)
        
cdef extern from "FL/Fl_Input_.H":
    cdef cppclass Fl_Input_:
        int value(char*)
        int value(char*, int)
        int static_value(char*)
        int static_value(char*, int)
        char* value()
        Fl_Char index(int i)
        int size()
        int cut()
        int copy(int clipboard)
        int undo()
        Fl_Font textfont()
        void textfont(Fl_Font s)
        Fl_Fontsize textsize()
        void textsize(Fl_Fontsize s)
        Fl_Color textcolor()
        void textcolor(Fl_Color n)
        Fl_Color cursor_color()
        void cursor_color(Fl_Color n)
        int _readonly "readonly"()
        void _readonly "readonly"(int b)
        int wrap()
        void wrap(int b)
        void tab_nav(int val)
        int tab_nav()

cdef extern from "FL/Fl_Input.H":
    cdef cppclass Fl_Input:
        Fl_Input(int X, int Y, int W, int H, char* L)

cdef extern from "FL/Fl_Float_Input.H":
    cdef cppclass Fl_Float_Input:
        Fl_Float_Input(int X, int Y, int W, int H, char* L)

cdef extern from "FL/Fl_Int_Input.H":
    cdef cppclass Fl_Int_Input:
        Fl_Int_Input(int X, int Y, int W, int H, char* L)

cdef extern from "FL/Fl_Multiline_Input.H":
    cdef cppclass Fl_Multiline_Input:
        Fl_Multiline_Input(int X, int Y, int W, int H, char* L)

cdef extern from "FL/Fl_Output.H":
    cdef cppclass Fl_Output:
        Fl_Output(int X, int Y, int W, int H, char* L)

cdef extern from "FL/Fl_Multiline_Output.H":
    cdef cppclass Fl_Multiline_Output:
        Fl_Multiline_Output(int X, int Y, int W, int H, char* L)
    
cdef extern from "FL/Fl_Shared_Image.H":
    cdef cppclass Fl_Shared_Image:
        pass
        
cdef extern from "FL/Fl_Help_View.H":
    
    #ctypedef Fl_Image *(*Fl_Image_Callback_p)(Fl_Widget *, void *, char *)
    ctypedef Fl_Image *(*Fl_Callback_p)(Fl_Widget *, void *, char *)
    
    cdef cppclass Fl_Help_View:
        Fl_Help_View(int xx, int yy, int ww, int hh, char *l)
        char *directory()
        char *filename()
        int	find(char *s, int p)
        # void link(Fl_Help_Func *fn)
        int load(char *f)
        void value(char *val)
        char *value()
        void textcolor(Fl_Color c)
        Fl_Color textcolor()
        void textfont(Fl_Font f)
        Fl_Font textfont()
        void textsize(Fl_Fontsize s)
        Fl_Fontsize textsize()
        char *title()
        void topline(char *n)
        void topline(int)
        int topline()
        void leftline(int)
        int leftline()
        void clear_selection()
        void select_all()
        
        void user_data(void* v)
        #void image_callback(Fl_Image_Callback_p cb)
        void callback(Fl_Callback_p cb)
  
cdef extern from "FL/Fl_Text_Buffer.H":
    cdef cppclass Fl_Text_Buffer:
        Fl_Text_Buffer(int, int)
        int length()
        char* text()
        void text(char* text)
        char* text_range(int start, int end)
        unsigned int char_at(int pos)
        char byte_at(int pos)
        void insert(int pos, char* text)
        void append(char* t)
        void remove(int start, int end)
        void replace(int start, int end, char *text)
        void copy(Fl_Text_Buffer* fromBuf, int fromStart, int fromEnd, int toPos)
        int undo(int *cp)
        void canUndo(char flag)
        int insertfile(char *file, int pos, int buflen)
        int appendfile(char *file, int buflen)
        int loadfile(char *file, int buflen)
        int outputfile(char *file, int start, int end, int buflen)
        int savefile(char *file, int buflen)
        int tab_distance()
        void tab_distance(int tabDist)
        void select(int start, int end)
        int selected()
        void unselect()
        int selection_position(int* start, int* end)
        char* selection_text()
        void remove_selection()
        void replace_selection(char* text)
        void secondary_select(int start, int end)
        int secondary_selected()
        void secondary_unselect()
        int secondary_selection_position(int* start, int* end)
        char* secondary_selection_text()
        void remove_secondary_selection()
        void replace_secondary_selection(char* text)
        void highlight(int start, int end)
        int highlight()
        void unhighlight()
        int highlight_position(int* start, int* end)
        char* highlight_text()
        char* line_text(int pos)
        int line_start(int pos)
        int line_end(int pos)
        int word_start(int pos)
        int word_end(int pos)
        int count_displayed_characters(int lineStartPos, int targetPos)
        int skip_displayed_characters(int lineStartPos, int nChars)
        int count_lines(int startPos, int endPos)
        int skip_lines(int startPos, int nLines)
        int rewind_lines(int startPos, int nLines)
        int findchar_forward(int startPos, unsigned searchChar, int* foundPos)
        int findchar_backward(int startPos, unsigned int searchChar, int* foundPos)
        int search_forward(int startPos, char* searchString, int* foundPos, int matchCase)
        int search_backward(int startPos, char* searchString, int* foundPos, int matchCase) 
        int prev_char(int ix)
        int prev_char_clipped(int ix)
        int utf8_align(int)

cdef extern from "FL/Fl_Text_Display.H":
    cdef cppclass Fl_Text_Display:
        Fl_Text_Display(int X, int Y, int W, int H, char *l)
        void buffer(Fl_Text_Buffer* buf)
        void redisplay_range(int start, int end)
        void scroll(int topLineNum, int horizOffset)
        void insert(char* text)
        void overstrike(char* text)
        void insert_position(int newPos)
        int insert_position()
        int in_selection(int x, int y)
        void show_insert_position()
        int move_right()
        int move_left()
        int move_up()
        int move_down()
        int count_lines(int start, int end, bint start_pos_is_line_start)
        int line_start(int pos)
        int line_end(int startPos, bint startPosIsLineStart)
        int skip_lines(int startPos, int nLines, bint startPosIsLineStart)
        int rewind_lines(int startPos, int nLines)
        void next_word()
        void previous_word()
        void show_cursor(int b)
        void hide_cursor()
        void cursor_style(int style)
        Fl_Color cursor_color()
        void cursor_color(Fl_Color n)
        int scrollbar_width()
        void scrollbar_width(int W)
        Fl_Align scrollbar_align()
        void scrollbar_align(Fl_Align a)
        int word_start(int pos)
        int word_end(int pos)
        Fl_Font textfont()
        void textfont(Fl_Font s)
        Fl_Fontsize textsize()
        void textsize(Fl_Fontsize s)
        Fl_Color textcolor()
        void textcolor(Fl_Color n)
        double x_to_col(double x)
        double col_to_x(double col)

cdef extern from "FL/Fl_Tree_Item.H":
    cdef cppclass Fl_Tree_Item:
        void label(char *val)
        char *label()
        int children()
        Fl_Tree_Item *parent()
        
cdef extern from "FL/Fl_Tree.H":
    ctypedef enum Fl_Tree_Reason:
        pass
        
    int FL_TREE_REASON_NONE
    int FL_TREE_REASON_SELECTED
    int FL_TREE_REASON_DESELECTED
    int FL_TREE_REASON_OPENED
    int FL_TREE_REASON_CLOSED
  
    cdef cppclass Fl_Tree:
        Fl_Tree(int X, int Y, int W, int H, char *L)
        Fl_Tree_Item *add(char *path)
        void clear()
        int showroot()
        void showroot(int val)
        Fl_Tree_Reason callback_reason()
        Fl_Tree_Item* callback_item()
        
cdef extern from "FL/Fl_Native_File_Chooser.H":
    cdef cppclass Fl_Native_File_Chooser:
        Fl_Native_File_Chooser(int val)
        void type(int val)
        int type()
        void options(int)
        int options()
        int count()
        char *filename()
        char *filename(int i)
        void directory(char *val)
        char *directory()
        void title(char *val)
        char *title()
        char *filter()
        void filter(char *val)
        int filters()
        void filter_value(int i)
        int filter_value()
        void preset_file(char *)
        char *preset_file()
        char *errmsg()
        int show()
        
cdef extern from "FL/fl_ask.H":
    void fl_message(char *, ...)
    void fl_alert(char *, ...)
    int fl_choice(char *q, char *b0, char *b1, char *b2,...)
    char *fl_input(char *label, char *deflt, ...)
    char *fl_password(char *label, char *deflt, ...)

cdef extern from "FL/fl_draw.H":
    int FL_SOLID
    int FL_DASH
    int FL_DOT
    int FL_DASHDOT
    int FL_DASHDOTDOT
    int FL_CAP_FLAT
    int FL_CAP_ROUND
    int FL_CAP_SQUARE
    int FL_JOIN_MITER
    int FL_JOIN_ROUND
    int FL_JOIN_BEVEL
    
    void fl_color(Fl_Color c)
    Fl_Color fl_color()
    void fl_point(int x, int y)
    void fl_line_style(int style, int width, char* dashes)
    void fl_rect(int x, int y, int w, int h)
    void fl_rect(int x, int y, int w, int h, Fl_Color c)
    void fl_rectf(int x, int y, int w, int h)
    void fl_rectf(int x, int y, int w, int h, Fl_Color c)
    void fl_rectf(int x, int y, int w, int h, uchar r, uchar g, uchar b)
    void fl_line(int x, int y, int x1, int y1)
    void fl_line(int x, int y, int x1, int y1, int x2, int y2)
    void fl_loop(int x, int y, int x1, int y1, int x2, int y2)
    void fl_loop(int x, int y, int x1, int y1, int x2, int y2, int x3, int y3)
    void fl_polygon(int x, int y, int x1, int y1, int x2, int y2)
    void fl_polygon(int x, int y, int x1, int y1, int x2, int y2, int x3, int y3)
    void fl_xyline(int x, int y, int x1)
    void fl_xyline(int x, int y, int x1, int y2)
    void fl_xyline(int x, int y, int x1, int y2, int x3)
    void fl_yxline(int x, int y, int y1)
    void fl_yxline(int x, int y, int y1, int x2)
    void fl_yxline(int x, int y, int y1, int x2, int y3)
    void fl_arc(int x, int y, int w, int h, double a1, double a2)
    void fl_pie(int x, int y, int w, int h, double a1, double a2)
    void fl_push_matrix()
    void fl_pop_matrix()
    void fl_scale(double x, double y)
    void fl_scale(double x)
    void fl_translate(double x, double y)
    void fl_rotate(double d)
    void fl_mult_matrix(double a, double b, double c, double d, double x,double y)
    void fl_begin_points()
    void fl_begin_line()
    void fl_begin_loop()
    void fl_begin_polygon()
    void fl_vertex(double x, double y)
    void fl_curve(double X0, double Y0, double X1, double Y1, double X2, double Y2, double X3, double Y3)
    void fl_arc(double x, double y, double r, double start, double end)
    void fl_circle(double x, double y, double r)
    void fl_end_points()
    void fl_end_line()
    void fl_end_loop()
    void fl_end_polygon()
    void fl_begin_complex_polygon()
    void fl_gap()
    void fl_end_complex_polygon()
    double fl_transform_x(double x, double y)
    double fl_transform_y(double x, double y)
    double fl_transform_dx(double x, double y)
    double fl_transform_dy(double x, double y)
    void fl_transformed_vertex(double xf, double yf)
    void fl_font(Fl_Font face, Fl_Fontsize size)
    Fl_Font fl_font()
    Fl_Fontsize fl_size()
    int fl_height()
    int fl_height(int font, int size)
    int fl_descent()
    double fl_width(char* txt)
    double fl_width(char* txt, int n)
    double fl_width(unsigned int)
    void fl_draw(char* str, int x, int y)
    void fl_draw(int angle, char* str, int x, int y)
    
    uchar* fl_read_image(uchar *p, int X, int Y, int W, int H, int alpha)
    void fl_draw_image(uchar* buf, int X,int Y,int W,int H, int D, int L)

cdef extern from "FL/Fl.H":
    cdef int Fl_run "Fl::run"()
    cdef int Fl_wait "Fl::wait"()
    cdef double Fl_version "Fl::version"()
    cdef int Fl_handle "Fl::handle"(int e, Fl_Window *window)
    cdef Fl_Window* Fl_first_window "Fl::first_window"()
    cdef int Fl_event "Fl::event"()
    cdef int Fl_event_x "Fl::event_x"()
    cdef int Fl_event_y "Fl::event_y"()
    cdef int Fl_event_x_root "Fl::event_x_root"()
    cdef int Fl_event_y_root "Fl::event_y_root"()
    cdef int Fl_event_dx "Fl::event_dx"()
    cdef int Fl_event_dy "Fl::event_dy"()
    cdef int Fl_event_clicks "Fl::event_clicks"()
    cdef int Fl_event_button "Fl::event_button"()
    cdef int Fl_event_key "Fl::event_key"()
    
    
cdef extern from "FL/x.H":
    ctypedef unsigned long Fl_Offscreen
    ctypedef unsigned long XID
    Fl_Offscreen fl_create_offscreen(int w, int h)
    void fl_delete_offscreen(Fl_Offscreen)
    void fl_begin_offscreen(Fl_Offscreen)
    void fl_end_offscreen()
    void fl_copy_offscreen(int x, int y, int w, int h, Fl_Offscreen osrc, int srcx, int srcy)
    XID fl_xid(Fl_Window *w)
