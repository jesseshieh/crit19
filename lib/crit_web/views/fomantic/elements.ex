defmodule CritWeb.Fomantic.Elements do
  use Phoenix.HTML
  import Phoenix.Controller, only: [get_flash: 2]
  import CritWeb.ErrorHelpers, only: [error_tag: 2]

  def error_flash_attached_above(conn),
    do: error_flash_above(conn, "ui negative attached message")

  def error_flash_above(conn),
    do: error_flash_above(conn, "ui negative message")

  def error_flash_above(conn, class) do
    if get_flash(conn, :error) do
      ~E"""
      <div class="<%=class%>">
        <%= get_flash(conn, :error) %>
      </div>
      """
    end
  end

  def success_flash_above(conn) do
    if get_flash(conn, :info) do
      ~E"""
      <div class="ui positive attached message">
        <%= get_flash(conn, :info) %>
      </div>
      """
    end
  end

  def note_changeset_errors(changeset) do
    if changeset.action do
      ~E"""
      <div class="ui negative attached message">
        Please fix the errors shown below.
      </div>
      """
    end
  end

  def centered_image(src) do
    classes = "ui center aligned container main" 
    
    ~E"""
    <div class="<%=classes%>">
      <img src=<%=src%>>
    </div>
    """
  end


  def start_centered_form do
    ~E"""
    <div class="ui middle aligned center aligned grid">
      <div class="left aligned column">
    """
  end

  def end_centered_form do
    ~E"""
    </div>
    </div>
    """
  end


  def list_link(text, module, action) do
    ~E"""
    <div class="item">
      <%= link text, to: apply(module, :path, [action]) %>
    </div>
    """
  end

  def dashboard_card(header, items) do
    ~E"""
    <div class="card">
      <div class="content">
        <div class="header">
          <%= header %>
        </div>
        <div class="ui left aligned list">
          <%= items %>
        </div>
      </div>
    </div>
    """
  end


  def login_form_style do
    ~E"""
    <style type="text/css">
        body {
          background-color: #DADADA;
        }
        .column {
          max-width: 350px;
        }
    </style>
    """
  end

  def small_calendar(f, label, target, opts) do
    unique_in_this_form = Keyword.fetch!(opts, :unique)
    # Used with JQuery to control the calendar.
    calendar = unique_ref(target, "calendar", unique_in_this_form)
    # id and name of the text field that shows the date.
    date = unique_ref(target, "date", unique_in_this_form)
    
    ~E"""
      <div data-controller="small-calendar"
           data-small-calendar-jquery-arg="#<%=calendar%>">
        <%= hidden_input f, target, data_target: "small-calendar.hidden" %>
        
        <div class="ui calendar" id="<%=calendar%>">
          <div class="field">
            <%= label f, target, label %>
            <div class="ui input left icon">
              <i class="calendar icon"></i>
              <%= text_input f, String.to_atom(date), 
                     readonly: true,
                     required: true,
                     value: "",
                     placeholder: "Click for a calendar",
                     data_target: "small-calendar.date" %>
              <%= error_tag f, target %>
            </div>
          </div>
        </div>
      </div>
    """
  end

  def calendar_with_alternatives(f, large_label, target, opts) do
    advice = Keyword.get(opts, :advice, "")
    radio_label = Keyword.fetch!(opts, :alternative)
    radio_value = String.downcase(radio_label)
    unique_in_this_form = Keyword.get(opts, :unique, "")

    # Used with JQuery to control the calendar.
    calendar = unique_ref(target, "calendar", unique_in_this_form)
    # id and name of the text field that shows the date.
    date = unique_ref(target, "date", unique_in_this_form)
    # id and name of the radio button
    radio = unique_ref(target, "radio", unique_in_this_form)
    
    ~E"""
    <div data-controller="calendar-with-alternatives"
         data-calendar-with-alternatives-jquery-arg="#<%=calendar%>"
         data-calendar-with-alternatives-radio-value="<%=radio_value%>"
         >

      <div class="field">
        <%= label f, target, large_label %>
        <%= advice %>
      </div>
      
      <%= hidden_input f, target,
            data_target: "calendar-with-alternatives.hidden" %>
    
      <div class="inline fields">
        <div class="field">
          <div class="ui calendar" id="<%=calendar%>">
            <div class="ui input left icon">
              <i class="calendar icon"></i>
              <input type="text" name="<%=date%>" id="<%=date%>"
                     readonly="true"
                     value=""
                     placeholder="Click for a calendar"
                     data-target="calendar-with-alternatives.date"/>
            </div>
          </div>
        </div>
        <div class="field">
          <div class="ui radio checkbox">
            <input type="radio" name="<%=radio%>" id="<%=radio%>"
                   checked="checked"
                   data-action="click->calendar-with-alternatives#propagate_from_radio_button"
                   data-target="calendar-with-alternatives.radio"/>
            <label for="<%=radio%>"><%=radio_label%></label>
          </div>
        </div>
      </div>
      <%= error_tag f, target %>
    </div>
    """
  end


  defp unique_ref(within_form_field, role, unique_form_id),
   do: "#{to_string(within_form_field)}_#{unique_form_id}_#{role}"
    
  

  def labeled_text_field(f, label, field, input_opts \\ []) do
    ~E"""
      <div class="field">
          <%= label f, field, label %>
          <%= text_input f, field, input_opts %>
          <%= error_tag f, field %>
      </div>
    """
  end

  def labeled_text_field_with_advice(f, label, field, advice, input_opts \\ []) do
    ~E"""
      <div class="field">
          <%= label f, field, label %>
          <%= advice %>
          <%= text_input f, field, input_opts %>
          <%= error_tag f, field %>
      </div>
    """
  end

  def labeled_textarea_with_advice(f, label, field, advice, input_opts \\ []) do
    ~E"""
      <div class="field">
          <%= label f, field, label %>
          <%= advice %>
          <%= textarea f, field, input_opts %>
          <%= error_tag f, field %>
      </div>
    """
  end

  def labeled_icon_field(f, label, field, icon, input_opts \\ []) do
    ~E"""
      <%= label f, field, label %>
      <div class="field">
          <div class="ui left icon input">
            <i class="<%=icon%>"></i>
            <%= text_input f, field, input_opts %>
          </div>
          <%= error_tag f, field %>
      </div>
    """
  end

  def labeled_checkbox(f, label, field, input_opts \\ []) do
    ~E"""
    <div class="field">
    <div class="ui checkbox">
        <%= checkbox(f, field, input_opts) %>
        <label><%=label%></label>
    </div>
    </div>
    """
  end

  def self_labeled_checkbox(f, field, opts \\ []) do
    labeled_checkbox(f, humanize(field), field, opts)
  end

  # Like `multiple_select`, but more convenient for user.
  def multiple_checkbox(f, structs, checkbox_field, opts \\ []) do
    for s <- structs do 
      multiple_checkbox_element(f, s, checkbox_field, opts)
    end
  end
  
  def multiple_checkbox_element(f, struct, checkbox_field, opts \\ []) do 
    opts = Enum.into(opts, %{sent_field: :id, displayed_field: :name})
    sent_value = Map.fetch!(struct, opts.sent_field)
    label_value = Map.fetch!(struct, opts.displayed_field)

    checkbox_id = input_id(f, checkbox_field, sent_value)
    checkbox_name = input_list_name(f, checkbox_field)

    checkbox_tag = tag(:input,
      name: checkbox_name,
      id: checkbox_id,
      type: "checkbox",
      value: sent_value)

    label_tag = content_tag(:label, label_value, for: checkbox_id)
    
    ~E"""
    <div class="field">
       <div class="ui checkbox">
         <%= checkbox_tag %>
         <%= label_tag %>
      </div>
    </div>
    """
  end

  def input_list_name(f, field), do: input_name(f, field) <> "[]"
  

  def big_submit_button(label) do
    submit label, class: "ui fluid large teal submit button"
  end

  @doc """
  This is a button that is *not* a Submit button (that is, it is
  not selected by Return/Enter, no matter where it is in the form). 
  It operates by calling a Javascript action
  """

  # The `type="button"` prevents it from becoming a `submit` button inside
  # a form.
  def negative_action_button(content, action) do
    ~E"""
      <button class="ui negative button"
              data-action="<%=action%>"
              type="button">
        <%= content %>
      </button>
    """
  end

  def dropdown_error_notification(has_errors) do
    if has_errors do 
      ~E"""
      <div class="ui negative attached message">
      <span>
        There were errors.
        (You may need to click the <i class="caret right icon"></i> arrows to see them.)
      </span>
      </div>
      """
    else
      []
    end
  end

  def dropdown(f, label, form_field, opts) do
    dropdown_id = Keyword.fetch!(opts, :dropdown_id)
    options = Keyword.fetch!(opts, :options)
    
    ~E"""
    <div class="field">
      <%= label f, form_field, label %>
      <%= select f, form_field, options, id: dropdown_id,
          class: "ui fluid dropdown" %>
    </div>
    """
  end
end
