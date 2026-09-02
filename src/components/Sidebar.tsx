import React from 'react';
import type { Agent, OfficeAgent, AgentGroup, OfficePreset, Theme, SidebarSections } from '../types';
import { ROLES, ROLE_COLORS } from '../utils/constants';

interface SidebarProps {
  filteredAgents: Agent[];
  selectedAgents: string[];
  officeAgents: OfficeAgent[];
  favorites: Set<string>;
  searchQuery: string;
  roleFilter: string | null;
  showFavoritesOnly: boolean;
  agentGroups: AgentGroup[];
  officePresets: OfficePreset[];
  theme: Theme;
  sidebarSections: SidebarSections;
  onSearchChange: (q: string) => void;
  onRoleFilterChange: (role: string | null) => void;
  onShowFavoritesOnly: (v: boolean) => void;
  onToggleAgent: (id: string) => void;
  onDoubleClickAgent: (agent: Agent) => void;
  onDragStart: (e: React.DragEvent, agent: Agent) => void;
  onShowAgentDetail: (id: string) => void;
  onToggleFavorite: (id: string) => void;
  onSelectAll: () => void;
  onDeselectAll: () => void;
  onClearOffice: () => void;
  onToggleTheme: () => void;
  onShowCustomAgent: () => void;
  onShowGroupSave: () => void;
  onShowPresetSave: () => void;
  onExportLayout: () => void;
  onImportLayout: (e: React.ChangeEvent<HTMLInputElement>) => void;
  onLoadGroup: (name: string) => void;
  onDeleteGroup: (name: string) => void;
  onLoadPreset: (name: string) => void;
  onDeletePreset: (name: string) => void;
  onSectionToggle: (section: keyof SidebarSections) => void;
}

export const Sidebar = React.memo(function Sidebar({
  filteredAgents,
  selectedAgents,
  officeAgents,
  favorites,
  searchQuery,
  roleFilter,
  showFavoritesOnly,
  agentGroups,
  officePresets,
  theme,
  sidebarSections,
  onSearchChange,
  onRoleFilterChange,
  onShowFavoritesOnly,
  onToggleAgent,
  onDoubleClickAgent,
  onDragStart,
  onShowAgentDetail,
  onToggleFavorite,
  onSelectAll,
  onDeselectAll,
  onClearOffice,
  onToggleTheme,
  onShowCustomAgent,
  onShowGroupSave,
  onShowPresetSave,
  onExportLayout,
  onImportLayout,
  onLoadGroup,
  onDeleteGroup,
  onLoadPreset,
  onDeletePreset,
  onSectionToggle,
}: SidebarProps) {
  return (
    <aside className="sidebar" role="complementary" aria-label="Agent sidebar">
      <div className="sidebar-content">
        <div className="sidebar-header">
          <span className="sidebar-title">Agents</span>
          <span className="agent-count" aria-label={`${filteredAgents.length} agents available`}>{filteredAgents.length}</span>
        </div>

        <input
          type="text"
          className="search-box"
          placeholder="Search agents… (⌘K)"
          value={searchQuery}
          onChange={e => onSearchChange(e.target.value)}
          aria-label="Search agents"
        />

        <div className="filter-pills" role="radiogroup" aria-label="Filter agents by role">
          <button className={`filter-pill ${roleFilter === null && !showFavoritesOnly ? 'active' : ''}`} onClick={() => { onRoleFilterChange(null); onShowFavoritesOnly(false); }} role="radio" aria-checked={roleFilter === null && !showFavoritesOnly}>All</button>
          <button className={`filter-pill ${showFavoritesOnly ? 'active' : ''}`} onClick={() => { onShowFavoritesOnly(!showFavoritesOnly); onRoleFilterChange(null); }} role="radio" aria-checked={showFavoritesOnly}> Favs</button>
          {ROLES.map(r => (
            <button key={r} className={`filter-pill ${roleFilter === r ? 'active' : ''}`} onClick={() => onRoleFilterChange(roleFilter === r ? null : r)} style={{ '--pill-color': ROLE_COLORS[r] } as React.CSSProperties}>
              {r}
            </button>
          ))}
        </div>

        <div className="sidebar-toolbar">
          <button onClick={onToggleTheme} className="toolbar-btn" title={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}>
            {theme === 'dark' ? '' : ''}
          </button>
          <button onClick={onShowCustomAgent} className="toolbar-btn" title="Add custom agent">+</button>
          <button onClick={onShowGroupSave} className="toolbar-btn" title="Save selected as group">Save</button>
          <button onClick={onShowPresetSave} className="toolbar-btn" title="Save office preset"></button>
          <button onClick={onExportLayout} className="toolbar-btn" title="Export layout"></button>
          <label className="toolbar-btn" title="Import layout">
            
            <input type="file" accept=".json" onChange={onImportLayout} hidden />
          </label>
        </div>

        {agentGroups.length > 0 && (
          <div className="groups-section">
            <div className="section-toggle" onClick={() => onSectionToggle('groups')}>
              <span className="agent-group-label" style={{ marginBottom: 0, paddingLeft: 0 }}>Groups</span>
              <span className="toggle-arrow">{sidebarSections.groups ? '▾' : '▸'}</span>
            </div>
            {sidebarSections.groups && agentGroups.map(g => (
              <div key={g.name} className="group-item">
                <button className="group-name" onClick={() => onLoadGroup(g.name)} title={`Load ${g.name}`}>
                  {g.name} <span className="group-count">{g.agentIds.length}</span>
                </button>
                <button className="group-delete" onClick={() => onDeleteGroup(g.name)} title="Delete group">×</button>
              </div>
            ))}
          </div>
        )}

        {officePresets.length > 0 && (
          <div className="groups-section">
            <div className="section-toggle" onClick={() => onSectionToggle('presets')}>
              <span className="agent-group-label" style={{ marginBottom: 0, paddingLeft: 0 }}>Office Presets</span>
              <span className="toggle-arrow">{sidebarSections.presets ? '▾' : '▸'}</span>
            </div>
            {sidebarSections.presets && officePresets.map(p => (
              <div key={p.name} className="group-item">
                <button className="group-name" onClick={() => onLoadPreset(p.name)} title={`Load ${p.name}`}>
                   {p.name} <span className="group-count">{p.agents.length}</span>
                </button>
                <button className="group-delete" onClick={() => onDeletePreset(p.name)} title="Delete preset">×</button>
              </div>
            ))}
          </div>
        )}

        <div className="agent-group">
          <div className="section-toggle" onClick={() => onSectionToggle('agents')}>
            <span className="agent-group-label" style={{ marginBottom: 0, paddingLeft: 0 }}>All Agents</span>
            <span className="toggle-arrow">{sidebarSections.agents ? '▾' : '▸'}</span>
          </div>
          {sidebarSections.agents && filteredAgents.map(agent => {
            const seated = officeAgents.find(a => a.id === agent.id);
            const roleColor = ROLE_COLORS[agent.office_role] || '#888';
            return (
              <div
                key={agent.id}
                className={`agent-item ${selectedAgents.includes(agent.id) ? 'selected' : ''}`}
                onClick={() => onToggleAgent(agent.id)}
                onDoubleClick={() => onDoubleClickAgent(agent)}
                draggable
                onDragStart={e => onDragStart(e, agent)}
                title={agent.description || agent.name}
                role="option"
                aria-selected={selectedAgents.includes(agent.id)}
                aria-label={`${agent.name}, ${agent.division}, role ${agent.office_role}${seated ? ', seated' : ''}`}
              >
                <div className="agent-avatar" style={{ backgroundColor: roleColor }}>
                  {agent.name.charAt(0).toUpperCase()}
                </div>
                <div className="agent-info">
                  <div className="agent-name" onClick={e => { e.stopPropagation(); onShowAgentDetail(agent.id); }}>{agent.name}</div>
                  <div className="agent-role">{agent.division} · {agent.office_role}</div>
                </div>
                {seated && <div className={`agent-status-dot ${seated.status}`} />}
                <span className={`agent-fav ${favorites.has(agent.id) ? 'active' : ''}`} onClick={e => { e.stopPropagation(); onToggleFavorite(agent.id); }} title={favorites.has(agent.id) ? 'Unfavorite' : 'Favorite'}>
                  {favorites.has(agent.id) ? '' : ''}
                </span>
                <div className={`agent-check ${selectedAgents.includes(agent.id) ? 'selected' : ''}`}>
                  {selectedAgents.includes(agent.id) && ''}
                </div>
              </div>
            );
          })}
        </div>
      </div>
      <div className="sidebar-bottom">
        <div className="select-actions">
          <button onClick={onSelectAll} className="link-btn">all</button>
          <span className="link-sep">|</span>
          <button onClick={onDeselectAll} className="link-btn">none</button>
          <span className="link-sep">|</span>
          <button onClick={onClearOffice} className="link-btn">clear desks</button>
        </div>
      </div>
    </aside>
  );
});
